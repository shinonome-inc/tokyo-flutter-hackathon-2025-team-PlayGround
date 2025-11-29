import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  TransactWriteCommand,
  TransactWriteCommandInput,
} from "@aws-sdk/lib-dynamodb";
import { v4 as uuidv4 } from "uuid";
import {
  RequestBody,
  RecipeResponse,
  Ingredient,
  Step,
  PresignedUrlResponse,
} from "./types/index";
import { getGeminiApiKey } from "./services/secretsManagerService";
import { generateRecipeText } from "./services/geminiService";
import { generateRecipeImage } from "./services/imagenService";
import {
  uploadImageToS3,
  downloadImageFromS3,
  generatePresignedUrl,
} from "./services/s3Service";
import { enrichRecipeContextWithImageIngredients } from "./services/ingredientDetectionService";

const client = new DynamoDBClient();
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

export const handler = async (
  event: APIGatewayProxyEvent | RequestBody
): Promise<APIGatewayProxyResult> => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  let requestBody: RequestBody;

  if ("body" in event && event.body) {
    console.log("Event body:", event.body);
    requestBody =
      typeof event.body === "string" ? JSON.parse(event.body) : event.body;
  } else if ("prompt" in event) {
    console.log("Direct Lambda invocation");
    requestBody = event as RequestBody;
  } else {
    return {
      statusCode: 400,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ error: "Request body is required" }),
    };
  }

  if (!requestBody.prompt || typeof requestBody.prompt !== "string") {
    return {
      statusCode: 400,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        error: "prompt is required and must be a string",
      }),
    };
  }

  if (!requestBody.userId || typeof requestBody.userId !== "string") {
    return {
      statusCode: 400,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        error: "userId is required and must be a string",
      }),
    };
  }

  // 画像アップロード用のpresigned URLを要求している場合
  if (requestBody.requiresImageUpload) {
    try {
      const imageS3Key = `${uuidv4()}.png`;
      const uploadUrl = await generatePresignedUrl(imageS3Key);

      const response: PresignedUrlResponse = {
        uploadUrl,
        imageS3Key,
      };

      return {
        statusCode: 200,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(response),
      };
    } catch (error) {
      console.error("Error generating presigned URL:", error);
      return {
        statusCode: 500,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          error: "Failed to generate presigned URL",
          message: error instanceof Error ? error.message : "Unknown error",
        }),
      };
    }
  }

  try {
    let recipePrompt = requestBody.prompt;

    if (requestBody.imageS3Key) {
      const imageBuffer = await downloadImageFromS3(requestBody.imageS3Key);
      recipePrompt = await enrichRecipeContextWithImageIngredients(
        imageBuffer,
        recipePrompt
      );
    }

    const recipe = await generateRecipeText(
      await getGeminiApiKey(),
      recipePrompt
    );

    const recipeId = uuidv4();
    const generatedImage = await generateRecipeImage(
      recipe.title,
      recipe.ingredients,
      recipe.overview
    );
    const imageUrl = await uploadImageToS3(generatedImage, `${recipeId}.png`);

    const ingredients: Ingredient[] = recipe.ingredients.map((ing) => ({
      id: uuidv4(),
      name: ing.name,
      amount: ing.amount,
    }));

    const steps: Step[] = recipe.steps.map((step, index) => ({
      orderNumber: index + 1,
      description: step,
    }));

    const createdAt = new Date().toISOString();
    const userId = requestBody.userId;

    // DynamoDBにレシピを保存
    const transactItems: TransactWriteCommandInput["TransactItems"] = [];

    // レシピ本体
    transactItems.push({
      Put: {
        TableName: TABLE_NAME,
        Item: {
          PK: `RECIPE#${recipeId}`,
          SK: `RECIPE#${recipeId}`,
          RecipeId: recipeId,
          UserId: userId,
          CreatedAt: createdAt,
          ImageUrl: imageUrl,
          Title: recipe.title,
          Notes: recipe.notes || "",
          IsAiGenerated: true,
          Overview: recipe.overview,
          EntityType: "RECIPE",
          // GSI1: ユーザーのレシピ一覧取得用
          GSI1PK: `USER#${userId}`,
          GSI1SK: `RECIPE#${createdAt}`,
          // GSI2: タイムライン用（公開レシピ）
          GSI2PK: "RECIPE_STATUS#PUB",
          GSI2SK: createdAt,
        },
      },
    });

    // 材料
    for (let i = 0; i < ingredients.length; i++) {
      const ingredient = ingredients[i];
      transactItems.push({
        Put: {
          TableName: TABLE_NAME,
          Item: {
            PK: `RECIPE#${recipeId}`,
            SK: `INGREDIENT#${String(i).padStart(3, "0")}#${ingredient.id}`,
            IngredientId: ingredient.id,
            RecipeId: recipeId,
            Name: ingredient.name,
            Amount: ingredient.amount,
            OrderIndex: i,
            EntityType: "INGREDIENT",
          },
        },
      });
    }

    // 手順
    for (let i = 0; i < steps.length; i++) {
      const step = steps[i];
      const stepId = uuidv4();
      transactItems.push({
        Put: {
          TableName: TABLE_NAME,
          Item: {
            PK: `RECIPE#${recipeId}`,
            SK: `STEP#${String(step.orderNumber).padStart(3, "0")}#${stepId}`,
            StepId: stepId,
            RecipeId: recipeId,
            OrderNumber: step.orderNumber,
            Description: step.description,
            EntityType: "STEP",
          },
        },
      });
    }

    await ddbDocClient.send(
      new TransactWriteCommand({
        TransactItems: transactItems,
      })
    );

    const response: RecipeResponse = {
      id: recipeId,
      title: recipe.title,
      overview: recipe.overview,
      imageUrl: imageUrl,
      isAiGenerated: true,
      createdAt: createdAt,
      user: {
        id: userId,
        name: requestBody.userName || "AI Recipe Generator",
        imageUrl: "",
        description: "AI generated recipe",
        emailAddress: "",
      },
      notes: recipe.notes,
      ingredients,
      steps,
      comments: [],
      isLikedByMe: false,
      likeCount: 0,
    };

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(response),
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        error: "Internal server error",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
    };
  }
};

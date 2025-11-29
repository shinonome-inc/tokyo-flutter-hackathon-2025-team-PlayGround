import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  TransactWriteCommand,
  TransactWriteCommandInput,
} from "@aws-sdk/lib-dynamodb";
import { v4 as uuidv4 } from "uuid";
import { verifyAndGetUserId } from "./utils/authUtils";

const client = new DynamoDBClient();
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

const corsHeaders = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST,OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type,Authorization",
};

interface Ingredient {
  name: string;
  amount: string;
}

interface Step {
  orderNumber: number;
  description: string;
}

interface RecipeRequestBody {
  imageUrl?: string;
  title: string;
  notes?: string;
  isAiGenerated?: boolean;
  overview: string;
  ingredients: Ingredient[];
  steps: Step[];
}

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  // CORS preflight対応
  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: "",
    };
  }

  try {
    // AuthorizationヘッダーからユーザーIDを取得（JWT検証付き）
    const authResult = await verifyAndGetUserId(event);
    if (!authResult.isValid || !authResult.userId) {
      return {
        statusCode: 401,
        headers: corsHeaders,
        body: JSON.stringify({
          message: "認証が必要です",
          error: authResult.error,
        }),
      };
    }
    const userId = authResult.userId;

    if (!event.body) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({
          message: "リクエストボディが必要です",
        }),
      };
    }

    const body: RecipeRequestBody = JSON.parse(event.body);
    const recipeId = uuidv4();
    const createdAt = new Date().toISOString();

    // トランザクションでレシピ、材料、手順を一括登録
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
          ImageUrl: body.imageUrl || "",
          Title: body.title,
          Notes: body.notes || "",
          IsAiGenerated: body.isAiGenerated || false,
          Overview: body.overview,
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
    for (let i = 0; i < body.ingredients.length; i++) {
      const ingredient = body.ingredients[i];
      const ingredientId = uuidv4();
      transactItems.push({
        Put: {
          TableName: TABLE_NAME,
          Item: {
            PK: `RECIPE#${recipeId}`,
            SK: `INGREDIENT#${String(i).padStart(3, "0")}#${ingredientId}`,
            IngredientId: ingredientId,
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
    for (let i = 0; i < body.steps.length; i++) {
      const step = body.steps[i];
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

    return {
      statusCode: 201,
      headers: corsHeaders,
      body: JSON.stringify({
        message: "レシピの作成に成功しました",
        recipeId: recipeId,
      }),
    };
  } catch (error) {
    console.error("Error creating recipe:", error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        message: `サーバーエラーが起きました: ${error}`,
      }),
    };
  }
};

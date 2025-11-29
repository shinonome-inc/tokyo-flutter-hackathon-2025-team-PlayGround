import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  TransactWriteCommand,
  TransactWriteCommandInput,
} from "@aws-sdk/lib-dynamodb";
import { v4 as uuidv4 } from "uuid";

const client = new DynamoDBClient();
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

interface Ingredient {
  name: string;
  amount: string;
}

interface Step {
  order_number: number;
  description: string;
}

interface RecipeRequestBody {
  user_id: string;
  created_at: string;
  updated_at: string;
  image_url: string;
  title: string;
  notes: string;
  is_ai_generated: boolean;
  overview: string;
  ingredients: Ingredient[];
  steps: Step[];
}

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    const body: RecipeRequestBody = JSON.parse(event.body!);
    const recipeId = uuidv4();
    const createdAt = body.created_at || new Date().toISOString();

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
          UserId: body.user_id,
          CreatedAt: createdAt,
          UpdatedAt: body.updated_at,
          ImageUrl: body.image_url,
          Title: body.title,
          Notes: body.notes,
          IsAiGenerated: body.is_ai_generated,
          Overview: body.overview,
          EntityType: "RECIPE",
          // GSI1: ユーザーのレシピ一覧取得用
          GSI1PK: `USER#${body.user_id}`,
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
            SK: `STEP#${String(step.order_number).padStart(3, "0")}#${stepId}`,
            StepId: stepId,
            RecipeId: recipeId,
            OrderNumber: step.order_number,
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
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({
        message: "レシピの作成に成功しました",
        recipeId: recipeId,
      }),
    };
  } catch (error) {
    console.error("Error creating recipe:", error);
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({
        message: `サーバーエラーが起きました: ${error}`,
      }),
    };
  }
};

import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient();
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

interface LikeRequestBody {
  userId: string;
}

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  // CORS preflight対応
  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST,DELETE,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type,Authorization",
      },
      body: "",
    };
  }

  try {
    // パスパラメータからrecipeIdを取得
    const recipeId = event.pathParameters?.recipeId;

    if (!recipeId) {
      return {
        statusCode: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: JSON.stringify({
          message: "recipeIdが指定されていません",
        }),
      };
    }

    // リクエストボディのパース
    if (!event.body) {
      return {
        statusCode: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: JSON.stringify({
          message: "リクエストボディが必要です",
        }),
      };
    }

    const body: LikeRequestBody = JSON.parse(event.body);

    // バリデーション
    if (!body.userId) {
      return {
        statusCode: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: JSON.stringify({
          message: "userIdは必須です",
        }),
      };
    }

    const createdAt = new Date().toISOString();

    // DynamoDBにいいねを保存
    // SK: LIKE#{user_id} の形式
    await ddbDocClient.send(
      new PutCommand({
        TableName: TABLE_NAME,
        Item: {
          PK: `RECIPE#${recipeId}`,
          SK: `LIKE#${body.userId}`,
          RecipeId: recipeId,
          UserId: body.userId,
          CreatedAt: createdAt,
          EntityType: "LIKE",
          // GSI1: ユーザーのいいね一覧取得用
          GSI1PK: `USER#${body.userId}`,
          GSI1SK: `LIKE#${createdAt}`,
        },
      })
    );

    return {
      statusCode: 201,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({
        isLiked: true,
      }),
    };
  } catch (error) {
    console.error("Error creating like:", error);
    return {
      statusCode: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({
        message: `サーバーエラーが発生しました: ${error}`,
      }),
    };
  }
};

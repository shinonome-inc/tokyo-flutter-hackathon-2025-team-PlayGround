import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  PutCommand,
  DeleteCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient();
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

const corsHeaders = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST,DELETE,OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type,Authorization",
};

/**
 * AuthorizationヘッダーからユーザーIDを取得する
 * JWTトークンをデコードしてsubクレームを抽出
 */
function getUserIdFromAuthHeader(event: APIGatewayProxyEvent): string | null {
  const authHeader = event.headers?.Authorization || event.headers?.authorization;
  if (!authHeader) {
    return null;
  }

  const token = authHeader.replace(/^Bearer\s+/i, "");
  try {
    // JWTのペイロード部分（2番目の部分）をデコード
    const payload = token.split(".")[1];
    const decoded = JSON.parse(Buffer.from(payload, "base64").toString("utf-8"));
    return decoded.sub || null;
  } catch {
    return null;
  }
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
    // AuthorizationヘッダーからユーザーIDを取得
    const userId = getUserIdFromAuthHeader(event);
    if (!userId) {
      return {
        statusCode: 401,
        headers: corsHeaders,
        body: JSON.stringify({
          message: "認証が必要です",
        }),
      };
    }

    // パスパラメータからrecipeIdを取得
    const recipeId = event.pathParameters?.recipeId;

    if (!recipeId) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({
          message: "recipeIdが指定されていません",
        }),
      };
    }

    // DELETEメソッドの場合はいいね削除
    if (event.httpMethod === "DELETE") {
      await ddbDocClient.send(
        new DeleteCommand({
          TableName: TABLE_NAME,
          Key: {
            PK: `RECIPE#${recipeId}`,
            SK: `LIKE#${userId}`,
          },
        })
      );

      return {
        statusCode: 204,
        headers: corsHeaders,
        body: "",
      };
    }

    // POSTメソッドの場合はいいね追加
    const createdAt = new Date().toISOString();

    // DynamoDBにいいねを保存
    // SK: LIKE#{user_id} の形式
    await ddbDocClient.send(
      new PutCommand({
        TableName: TABLE_NAME,
        Item: {
          PK: `RECIPE#${recipeId}`,
          SK: `LIKE#${userId}`,
          RecipeId: recipeId,
          UserId: userId,
          CreatedAt: createdAt,
          EntityType: "LIKE",
          // GSI1: ユーザーのいいね一覧取得用
          GSI1PK: `USER#${userId}`,
          GSI1SK: `LIKE#${createdAt}`,
        },
      })
    );

    return {
      statusCode: 201,
      headers: corsHeaders,
      body: JSON.stringify({
        isLiked: true,
      }),
    };
  } catch (error) {
    console.error("Error processing like:", error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        message: `サーバーエラーが発生しました: ${error}`,
      }),
    };
  }
};

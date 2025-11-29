import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  PutCommand,
  GetCommand,
} from "@aws-sdk/lib-dynamodb";
import { v4 as uuidv4 } from "uuid";

const client = new DynamoDBClient();
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

const corsHeaders = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST,OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type,Authorization",
};

interface CommentRequestBody {
  description: string;
}

interface Comment {
  id: string;
  userId: string;
  userName: string;
  description: string;
  createdAt: string;
}

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

    // リクエストボディのパース
    if (!event.body) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({
          message: "リクエストボディが必要です",
        }),
      };
    }

    const body: CommentRequestBody = JSON.parse(event.body);

    // バリデーション
    if (!body.description) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({
          message: "descriptionは必須です",
        }),
      };
    }

    // ユーザー情報を取得してuserNameを取得
    const userResult = await ddbDocClient.send(
      new GetCommand({
        TableName: TABLE_NAME,
        Key: {
          PK: `USER#${userId}`,
          SK: "PROFILE",
        },
      })
    );

    const userName = userResult.Item?.UserName || "Unknown User";

    // コメントIDと作成日時を生成
    const commentId = uuidv4();
    const createdAt = new Date().toISOString();

    // DynamoDBにコメントを保存
    // SK: COMMENT#{created_at}#{id} の形式
    await ddbDocClient.send(
      new PutCommand({
        TableName: TABLE_NAME,
        Item: {
          PK: `RECIPE#${recipeId}`,
          SK: `COMMENT#${createdAt}#${commentId}`,
          CommentId: commentId,
          RecipeId: recipeId,
          UserId: userId,
          UserName: userName,
          Description: body.description,
          CreatedAt: createdAt,
          EntityType: "COMMENT",
        },
      })
    );

    // レスポンス用のコメントオブジェクト
    const comment: Comment = {
      id: commentId,
      userId: userId,
      userName: userName,
      description: body.description,
      createdAt: createdAt,
    };

    return {
      statusCode: 201,
      headers: corsHeaders,
      body: JSON.stringify(comment),
    };
  } catch (error) {
    console.error("Error creating comment:", error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        message: `サーバーエラーが発生しました: ${error}`,
      }),
    };
  }
};

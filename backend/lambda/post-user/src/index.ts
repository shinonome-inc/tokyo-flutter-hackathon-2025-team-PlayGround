import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient();
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

const corsHeaders = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type,Authorization",
};

interface UserRequestBody {
  name?: string;
  emailAddress: string;
  imageUrl?: string;
}

interface User {
  id: string;
  name: string;
  imageUrl: string;
  description: string;
  emailAddress: string;
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

    const body: UserRequestBody = JSON.parse(event.body);

    // バリデーション
    if (!body.emailAddress) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({
          message: "emailAddressは必須です",
        }),
      };
    }

    const createdAt = new Date().toISOString();
    const userName = body.name || "";
    const imageUrl = body.imageUrl || "";

    // DynamoDBにユーザーを保存
    await ddbDocClient.send(
      new PutCommand({
        TableName: TABLE_NAME,
        Item: {
          PK: `USER#${userId}`,
          SK: "PROFILE",
          UserId: userId,
          UserName: userName,
          ImageUrl: imageUrl,
          Description: "",
          EmailAddress: body.emailAddress,
          CreatedAt: createdAt,
          UpdatedAt: createdAt,
          EntityType: "USER",
          // GSI2: ユーザー一覧取得用（新しい順）
          GSI2PK: "USER_STATUS#ACTIVE",
          GSI2SK: createdAt,
          // GSI3: メールアドレスからユーザー検索用
          GSI3PK: `EMAIL#${body.emailAddress}`,
          GSI3SK: "PROFILE",
        },
      })
    );

    // レスポンス用のユーザーオブジェクト
    const user: User = {
      id: userId,
      name: userName,
      imageUrl: imageUrl,
      description: "",
      emailAddress: body.emailAddress,
    };

    return {
      statusCode: 201,
      headers: corsHeaders,
      body: JSON.stringify(user),
    };
  } catch (error) {
    console.error("Error creating user:", error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        message: `サーバーエラーが発生しました: ${error}`,
      }),
    };
  }
};

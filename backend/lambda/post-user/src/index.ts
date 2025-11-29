import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, PutCommand } from "@aws-sdk/lib-dynamodb";
import { v4 as uuidv4 } from "uuid";

const client = new DynamoDBClient();
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

interface UserRequestBody {
  name?: string;
  email_address: string;
  image_url?: string;
}

interface User {
  id: string;
  name: string;
  image_url: string;
  description: string;
  email_address: string;
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
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type,Authorization",
      },
      body: "",
    };
  }

  try {
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

    const body: UserRequestBody = JSON.parse(event.body);

    // バリデーション
    if (!body.email_address) {
      return {
        statusCode: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: JSON.stringify({
          message: "email_addressは必須です",
        }),
      };
    }

    const userId = uuidv4();
    const createdAt = new Date().toISOString();
    const userName = body.name || "";
    const imageUrl = body.image_url || "";

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
          EmailAddress: body.email_address,
          CreatedAt: createdAt,
          UpdatedAt: createdAt,
          EntityType: "USER",
          // GSI2: ユーザー一覧取得用（新しい順）
          GSI2PK: "USER_STATUS#ACTIVE",
          GSI2SK: createdAt,
          // GSI3: メールアドレスからユーザー検索用
          GSI3PK: `EMAIL#${body.email_address}`,
          GSI3SK: "PROFILE",
        },
      })
    );

    // レスポンス用のユーザーオブジェクト
    const user: User = {
      id: userId,
      name: userName,
      image_url: imageUrl,
      description: "",
      email_address: body.email_address,
    };

    return {
      statusCode: 201,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify(user),
    };
  } catch (error) {
    console.error("Error creating user:", error);
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

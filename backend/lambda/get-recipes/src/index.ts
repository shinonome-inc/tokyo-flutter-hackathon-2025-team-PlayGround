import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  QueryCommand,
  BatchGetCommand,
} from "@aws-sdk/lib-dynamodb";

let docClient: DynamoDBDocumentClient | null = null;

/**
 * DynamoDB Document Clientを取得する（遅延初期化）
 */
function getDocClient(): DynamoDBDocumentClient {
  if (!docClient) {
    const client = new DynamoDBClient({});
    docClient = DynamoDBDocumentClient.from(client);
  }
  return docClient;
}

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

interface User {
  id: string;
  name: string;
  imageUrl: string;
  description: string;
  emailAddress: string;
}

interface RecipeOverview {
  id: string;
  title: string;
  overview: string;
  imageUrl: string;
  isAiGenerated: boolean;
  createdAt: string;
  user: User;
}

/**
 * GSI2を使用してタイムライン（全レシピ）を新着順で取得する
 */
async function getRecipesFromTimeline(): Promise<RecipeOverview[]> {
  const command = new QueryCommand({
    TableName: TABLE_NAME,
    IndexName: "GSI2",
    KeyConditionExpression: "GSI2PK = :pk",
    ExpressionAttributeValues: {
      ":pk": "RECIPE_STATUS#PUB",
    },
    ScanIndexForward: false,
    Limit: 50,
  });

  const result = await getDocClient().send(command);

  if (!result.Items || result.Items.length === 0) {
    return [];
  }

  const userIds = [...new Set(result.Items.map((item) => item.user_id as string))];

  const users = await batchGetUsers(userIds);

  return result.Items.map((item: Record<string, unknown>) => ({
    id: (item.PK as string).replace("RECIPE#", ""),
    title: item.title as string,
    overview: item.overview as string,
    imageUrl: (item.image_url as string) || "",
    isAiGenerated: (item.is_ai_generated as boolean) || false,
    createdAt: item.created_at as string,
    user: users[item.user_id as string] || {
      id: item.user_id as string,
      name: "Unknown",
      imageUrl: "",
      description: "",
      emailAddress: "",
    },
  }));
}

/**
 * ユーザー情報をバッチ取得する
 */
async function batchGetUsers(
  userIds: string[]
): Promise<Record<string, User>> {
  if (userIds.length === 0) {
    return {};
  }

  const keys = userIds.map((userId) => ({
    PK: `USER#${userId}`,
    SK: "PROFILE",
  }));

  const command = new BatchGetCommand({
    RequestItems: {
      [TABLE_NAME]: {
        Keys: keys,
      },
    },
  });

  const result = await getDocClient().send(command);
  const users: Record<string, User> = {};

  if (result.Responses && result.Responses[TABLE_NAME]) {
    for (const item of result.Responses[TABLE_NAME]) {
      const userId = item.PK.replace("USER#", "");
      users[userId] = {
        id: userId,
        name: item.name || "",
        imageUrl: item.image_url || "",
        description: item.description || "",
        emailAddress: item.email_address || "",
      };
    }
  }

  return users;
}

/**
 * Lambda ハンドラー
 */
export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  const corsHeaders = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
  };

  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: "",
    };
  }

  try {
    const recipes = await getRecipesFromTimeline();

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify(recipes),
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        error: "Internal server error",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
    };
  }
};

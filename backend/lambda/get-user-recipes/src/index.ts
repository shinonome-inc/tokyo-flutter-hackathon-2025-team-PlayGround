import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  QueryCommand,
  GetCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type,Authorization",
};

interface User {
  id: string;
  name: string;
  image_url: string;
  description: string;
  email_address: string;
}

interface RecipeOverview {
  id: string;
  title: string;
  overview: string;
  image_url: string;
  is_ai_generated: boolean;
  created_at: string;
  user: User;
}

/**
 * ユーザー情報を取得する
 */
async function getUser(userId: string): Promise<User | null> {
  const result = await ddbDocClient.send(
    new GetCommand({
      TableName: TABLE_NAME,
      Key: {
        PK: `USER#${userId}`,
        SK: "PROFILE",
      },
    })
  );

  if (!result.Item) {
    return null;
  }

  return {
    id: result.Item.UserId || userId,
    name: result.Item.UserName || "",
    image_url: result.Item.ImageUrl || "",
    description: result.Item.Description || "",
    email_address: result.Item.EmailAddress || "",
  };
}

/**
 * GSI1を使用して特定ユーザーのレシピ一覧を取得する
 */
async function getUserRecipes(
  userId: string,
  user: User
): Promise<RecipeOverview[]> {
  const result = await ddbDocClient.send(
    new QueryCommand({
      TableName: TABLE_NAME,
      IndexName: "GSI1",
      KeyConditionExpression: "GSI1PK = :pk",
      ExpressionAttributeValues: {
        ":pk": `USER#${userId}`,
      },
      ScanIndexForward: false,
      Limit: 50,
    })
  );

  if (!result.Items || result.Items.length === 0) {
    return [];
  }

  return result.Items.map((item: Record<string, unknown>) => ({
    id: (item.PK as string).replace("RECIPE#", ""),
    title: (item.title as string) || "",
    overview: (item.overview as string) || "",
    image_url: (item.image_url as string) || "",
    is_ai_generated: (item.is_ai_generated as boolean) || false,
    created_at: (item.created_at as string) || "",
    user: user,
  }));
}

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: "",
    };
  }

  try {
    const userId = event.pathParameters?.userId;

    if (!userId) {
      return {
        statusCode: 400,
        headers: corsHeaders,
        body: JSON.stringify({
          message: "userId is required",
        }),
      };
    }

    // ユーザー情報を取得
    const user = await getUser(userId);

    if (!user) {
      return {
        statusCode: 404,
        headers: corsHeaders,
        body: JSON.stringify({
          message: "User not found",
        }),
      };
    }

    // ユーザーのレシピ一覧を取得
    const recipes = await getUserRecipes(userId, user);

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify(recipes),
    };
  } catch (error) {
    console.error("Error fetching user recipes:", error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        message: "サーバーエラーが発生しました",
      }),
    };
  }
};

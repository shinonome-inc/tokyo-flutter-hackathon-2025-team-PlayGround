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
    imageUrl: result.Item.ImageUrl || "",
    description: result.Item.Description || "",
    emailAddress: result.Item.EmailAddress || "",
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
    title: (item.Title as string) || "",
    overview: (item.Overview as string) || "",
    imageUrl: (item.ImageUrl as string) || "",
    isAiGenerated: (item.IsAiGenerated as boolean) || false,
    createdAt: (item.CreatedAt as string) || "",
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

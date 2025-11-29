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

interface Ingredient {
  id: string;
  name: string;
  amount: string;
}

interface RecipeOverview {
  id: string;
  title: string;
  overview: string;
  imageUrl: string;
  isAiGenerated: boolean;
  createdAt: string;
  user: User;
  ingredients: Ingredient[];
  likeCount: number;
}

function convertStrToBoolean(booleanStr: string): boolean {
  if (booleanStr === "true") {
    return true;
  }
  return false;
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

  const userIds = [...new Set(result.Items.map((item) => item.UserId as string))];
  const recipeIds = result.Items.map((item) => (item.PK as string).replace("RECIPE#", ""));

  // ユーザー情報と各レシピの詳細（材料、いいね）を並行で取得
  const [users, recipeDetails] = await Promise.all([
    batchGetUsers(userIds),
    getRecipeDetails(recipeIds),
  ]);

  return result.Items.map((item: Record<string, unknown>) => {
    const recipeId = (item.PK as string).replace("RECIPE#", "");
    const details = recipeDetails[recipeId] || { ingredients: [], likeCount: 0 }; 
    const isAiGenerated = convertStrToBoolean(item.IsAiGenerated as string);

    return {
      id: recipeId,
      title: item.Title as string,
      overview: item.Overview as string,
      imageUrl: (item.ImageUrl as string) || "",
      isAiGenerated: isAiGenerated,
      createdAt: item.CreatedAt as string,
      user: users[item.UserId as string] || {
        id: item.UserId as string,
        name: "Unknown",
        imageUrl: "",
        description: "",
        emailAddress: "",
      },
      ingredients: details.ingredients,
      likeCount: details.likeCount,
    };
  });
}

/**
 * 各レシピの材料といいね数を取得する
 */
async function getRecipeDetails(
  recipeIds: string[]
): Promise<Record<string, { ingredients: Ingredient[]; likeCount: number }>> {
  if (recipeIds.length === 0) {
    return {};
  }

  // 各レシピのPKでQueryを並行実行
  const queries = recipeIds.map((recipeId) =>
    getDocClient().send(
      new QueryCommand({
        TableName: TABLE_NAME,
        KeyConditionExpression: "PK = :pk",
        ExpressionAttributeValues: {
          ":pk": `RECIPE#${recipeId}`,
        },
      })
    )
  );

  const results = await Promise.all(queries);
  const details: Record<string, { ingredients: Ingredient[]; likeCount: number }> = {};

  recipeIds.forEach((recipeId, index) => {
    const items = results[index].Items || [];

    // 材料を抽出（SKがINGREDIENT#で始まるもの）
    const ingredients: Ingredient[] = items
      .filter((item) => (item.SK as string).startsWith("INGREDIENT#"))
      .map((item) => ({
        id: item.IngredientId as string,
        name: item.Name as string,
        amount: (item.Amount as string) || "",
      }))
      .sort((a, b) => {
        // OrderIndexでソート
        const aIndex = items.find((i) => i.IngredientId === a.id)?.OrderIndex || 0;
        const bIndex = items.find((i) => i.IngredientId === b.id)?.OrderIndex || 0;
        return (aIndex as number) - (bIndex as number);
      });

    // いいね数をカウント（SKがLIKE#で始まるもの）
    const likeCount = items.filter((item) => (item.SK as string).startsWith("LIKE#")).length;

    details[recipeId] = { ingredients, likeCount };
  });

  return details;
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
        name: item.UserName || "",
        imageUrl: item.ImageUrl || "",
        description: item.Description || "",
        emailAddress: item.EmailAddress || "",
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

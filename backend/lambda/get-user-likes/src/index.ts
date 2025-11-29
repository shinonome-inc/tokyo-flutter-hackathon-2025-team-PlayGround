import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  QueryCommand,
  GetCommand,
  BatchGetCommand,
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

interface LikedRecipe {
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
 * GSI1を使用して特定ユーザーのいいね一覧を取得する
 */
async function getUserLikes(userId: string): Promise<LikedRecipe[]> {
  // GSI1を使ってユーザーのいいね一覧を取得（新しい順）
  const likesResult = await ddbDocClient.send(
    new QueryCommand({
      TableName: TABLE_NAME,
      IndexName: "GSI1",
      KeyConditionExpression: "GSI1PK = :pk AND begins_with(GSI1SK, :sk)",
      ExpressionAttributeValues: {
        ":pk": `USER#${userId}`,
        ":sk": "LIKE#",
      },
      ScanIndexForward: false,
      Limit: 50,
    })
  );

  if (!likesResult.Items || likesResult.Items.length === 0) {
    return [];
  }

  // いいねしたレシピのIDを抽出
  const recipeIds = likesResult.Items.map((item) => item.RecipeId as string);
  const likedAtMap = new Map<string, string>();
  likesResult.Items.forEach((item) => {
    likedAtMap.set(item.RecipeId as string, item.CreatedAt as string);
  });

  // レシピの詳細情報をバッチ取得
  const batchGetResult = await ddbDocClient.send(
    new BatchGetCommand({
      RequestItems: {
        [TABLE_NAME]: {
          Keys: recipeIds.map((recipeId) => ({
            PK: `RECIPE#${recipeId}`,
            SK: `RECIPE#${recipeId}`,
          })),
        },
      },
    })
  );

  const recipes = batchGetResult.Responses?.[TABLE_NAME] || [];

  // レシピの投稿者IDを収集
  const userIds = [...new Set(recipes.map((recipe) => recipe.UserId as string))];

  // ユーザー情報をバッチ取得
  const usersResult = await ddbDocClient.send(
    new BatchGetCommand({
      RequestItems: {
        [TABLE_NAME]: {
          Keys: userIds.map((uid) => ({
            PK: `USER#${uid}`,
            SK: "PROFILE",
          })),
        },
      },
    })
  );

  const usersMap = new Map<string, User>();
  (usersResult.Responses?.[TABLE_NAME] || []).forEach((item) => {
    const uid = item.UserId as string;
    usersMap.set(uid, {
      id: uid,
      name: (item.UserName as string) || "",
      imageUrl: (item.ImageUrl as string) || "",
      description: (item.Description as string) || "",
      emailAddress: (item.EmailAddress as string) || "",
    });
  });

  // いいね順（新しい順）でレシピ情報を返す
  return recipeIds
    .map((recipeId) => {
      const recipe = recipes.find(
        (r) => r.RecipeId === recipeId
      );
      if (!recipe) return null;

      const recipeUserId = recipe.UserId as string;
      const user = usersMap.get(recipeUserId) || {
        id: recipeUserId,
        name: "",
        imageUrl: "",
        description: "",
        emailAddress: "",
      };

      return {
        id: recipeId,
        title: (recipe.Title as string) || "",
        overview: (recipe.Overview as string) || "",
        imageUrl: (recipe.ImageUrl as string) || "",
        isAiGenerated: (recipe.IsAiGenerated as boolean) || false,
        createdAt: (recipe.CreatedAt as string) || "",
        user,
      };
    })
    .filter((r): r is LikedRecipe => r !== null);
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

    // ユーザーの存在確認
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

    // ユーザーのいいね一覧を取得
    const likedRecipes = await getUserLikes(userId);

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify(likedRecipes),
    };
  } catch (error) {
    console.error("Error fetching user likes:", error);
    return {
      statusCode: 500,
      headers: corsHeaders,
      body: JSON.stringify({
        message: "サーバーエラーが発生しました",
      }),
    };
  }
};

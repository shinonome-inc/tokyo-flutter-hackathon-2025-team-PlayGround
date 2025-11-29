import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  QueryCommand,
  GetCommand,
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

interface Step {
  orderNumber: number;
  description: string;
}

interface Comment {
  id: string;
  userId: string;
  userName: string;
  description: string;
  createdAt: string;
}

interface RecipeDetail {
  id: string;
  title: string;
  overview: string;
  notes: string;
  imageUrl: string;
  isAiGenerated: boolean;
  createdAt: string;
  user: User;
  ingredients: Ingredient[];
  steps: Step[];
  comments: Comment[];
  isLikedByMe: boolean;
  likeCount: number;
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

/**
 * レシピIDに紐づく全アイテム（レシピ本体、材料、手順）を取得する
 */
async function getRecipeItems(
  recipeId: string
): Promise<Record<string, unknown>[]> {
  const command = new QueryCommand({
    TableName: TABLE_NAME,
    KeyConditionExpression: "PK = :pk",
    ExpressionAttributeValues: {
      ":pk": `RECIPE#${recipeId}`,
    },
  });

  const result = await getDocClient().send(command);
  return result.Items || [];
}

/**
 * ユーザー情報を取得する
 */
async function getUser(userId: string): Promise<User | null> {
  const command = new GetCommand({
    TableName: TABLE_NAME,
    Key: {
      PK: `USER#${userId}`,
      SK: "PROFILE",
    },
  });

  const result = await getDocClient().send(command);

  if (!result.Item) {
    return null;
  }

  return {
    id: userId,
    name: result.Item.name || "",
    imageUrl: result.Item.image_url || "",
    description: result.Item.description || "",
    emailAddress: result.Item.email_address || "",
  };
}

/**
 * レシピ詳細を組み立てる
 */
function buildRecipeDetail(
  recipeId: string,
  items: Record<string, unknown>[],
  user: User,
  currentUserId: string | null
): RecipeDetail | null {
  const recipeItem = items.find(
    (item) => item.SK === `RECIPE#${recipeId}`
  );

  if (!recipeItem) {
    return null;
  }

  const ingredients: Ingredient[] = items
    .filter((item) => (item.SK as string).startsWith("INGREDIENT#"))
    .map((item) => ({
      id: item.IngredientId as string,
      name: item.Name as string,
      amount: item.Amount as string,
      orderIndex: item.OrderIndex as number,
    }))
    .sort((a, b) => a.orderIndex - b.orderIndex)
    .map(({ orderIndex, ...rest }) => rest);

  const steps: Step[] = items
    .filter((item) => (item.SK as string).startsWith("STEP#"))
    .map((item) => ({
      orderNumber: item.OrderNumber as number,
      description: item.Description as string,
    }))
    .sort((a, b) => a.orderNumber - b.orderNumber);

  // コメントを抽出
  const comments: Comment[] = items
    .filter((item) => (item.SK as string).startsWith("COMMENT#"))
    .map((item) => ({
      id: item.CommentId as string,
      userId: item.UserId as string,
      userName: (item.UserName as string) || "",
      description: item.Description as string,
      createdAt: item.CreatedAt as string,
    }))
    .sort((a, b) => new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime());

  // いいねを抽出
  const likes = items.filter((item) => (item.SK as string).startsWith("LIKE#"));
  const likeCount = likes.length;
  const isLikedByMe = currentUserId
    ? likes.some((item) => item.SK === `LIKE#${currentUserId}`)
    : false;

  return {
    id: recipeId,
    title: recipeItem.Title as string,
    overview: recipeItem.Overview as string,
    notes: (recipeItem.Notes as string) || "",
    imageUrl: (recipeItem.ImageUrl as string) || "",
    isAiGenerated: (recipeItem.IsAiGenerated as boolean) || false,
    createdAt: recipeItem.CreatedAt as string,
    user,
    ingredients,
    steps,
    comments,
    isLikedByMe,
    likeCount,
  };
}

const corsHeaders = {
  "Content-Type": "application/json",
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
};

/**
 * レシピ詳細取得のLambdaハンドラー
 */
export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  console.log("Received event:", JSON.stringify(event, null, 2));

  if (event.httpMethod === "OPTIONS") {
    return {
      statusCode: 200,
      headers: corsHeaders,
      body: "",
    };
  }

  const recipeId = event.pathParameters?.recipeId;

  if (!recipeId) {
    return {
      statusCode: 400,
      headers: corsHeaders,
      body: JSON.stringify({
        error: "Bad Request",
        message: "recipeId is required",
      }),
    };
  }

  try {
    // AuthorizationヘッダーからユーザーIDを取得（オプション）
    const currentUserId = getUserIdFromAuthHeader(event);

    const items = await getRecipeItems(recipeId);

    if (items.length === 0) {
      return {
        statusCode: 404,
        headers: corsHeaders,
        body: JSON.stringify({
          error: "Not Found",
          message: "Recipe not found",
        }),
      };
    }

    const recipeItem = items.find(
      (item) => item.SK === `RECIPE#${recipeId}`
    );

    if (!recipeItem) {
      return {
        statusCode: 404,
        headers: corsHeaders,
        body: JSON.stringify({
          error: "Not Found",
          message: "Recipe not found",
        }),
      };
    }

    const userId = recipeItem.UserId as string;
    const user = await getUser(userId);

    const recipeDetail = buildRecipeDetail(recipeId, items, user || {
      id: userId,
      name: "Unknown",
      imageUrl: "",
      description: "",
      emailAddress: "",
    }, currentUserId);

    if (!recipeDetail) {
      return {
        statusCode: 404,
        headers: corsHeaders,
        body: JSON.stringify({
          error: "Not Found",
          message: "Recipe not found",
        }),
      };
    }

    return {
      statusCode: 200,
      headers: corsHeaders,
      body: JSON.stringify(recipeDetail),
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

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

interface CommentRequestBody {
  user_id: string;
  description: string;
}

interface Comment {
  id: string;
  user_id: string;
  user_name: string;
  description: string;
  created_at: string;
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
        "Access-Control-Allow-Methods": "POST,OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type,Authorization",
      },
      body: "",
    };
  }

  try {
    // パスパラメータからrecipeIdを取得
    const recipeId = event.pathParameters?.recipeId;

    if (!recipeId) {
      return {
        statusCode: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: JSON.stringify({
          message: "recipeIdが指定されていません",
        }),
      };
    }

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

    const body: CommentRequestBody = JSON.parse(event.body);

    // バリデーション
    if (!body.description) {
      return {
        statusCode: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: JSON.stringify({
          message: "descriptionは必須です",
        }),
      };
    }

    if (!body.user_id) {
      return {
        statusCode: 400,
        headers: {
          "Content-Type": "application/json",
          "Access-Control-Allow-Origin": "*",
        },
        body: JSON.stringify({
          message: "user_idは必須です",
        }),
      };
    }

    // ユーザー情報を取得してuser_nameを取得
    const userResult = await ddbDocClient.send(
      new GetCommand({
        TableName: TABLE_NAME,
        Key: {
          PK: `USER#${body.user_id}`,
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
          UserId: body.user_id,
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
      user_id: body.user_id,
      user_name: userName,
      description: body.description,
      created_at: createdAt,
    };

    return {
      statusCode: 201,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify(comment),
    };
  } catch (error) {
    console.error("Error creating comment:", error);
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

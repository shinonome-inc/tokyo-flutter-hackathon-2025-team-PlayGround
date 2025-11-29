import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, QueryCommand } from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient();
const ddbDocClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || "";

interface User {
  id: string;
  name: string;
  imageUrl: string;
  description: string;
  emailAddress: string;
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
    const email = event.queryStringParameters?.email;

    let users: User[] = [];

    if (email) {
      // メールアドレスからユーザーを検索（GSI3）
      const result = await ddbDocClient.send(
        new QueryCommand({
          TableName: TABLE_NAME,
          IndexName: "GSI3",
          KeyConditionExpression: "GSI3PK = :pk AND GSI3SK = :sk",
          ExpressionAttributeValues: {
            ":pk": `EMAIL#${email}`,
            ":sk": "PROFILE",
          },
        })
      );

      if (result.Items && result.Items.length > 0) {
        users = result.Items.map((item) => ({
          id: item.UserId,
          name: item.UserName || "",
          imageUrl: item.ImageUrl || "",
          description: item.Description || "",
          emailAddress: item.EmailAddress || "",
        }));
      }
    } else {
      // 全ユーザーを新しい順に取得（GSI2）
      const result = await ddbDocClient.send(
        new QueryCommand({
          TableName: TABLE_NAME,
          IndexName: "GSI2",
          KeyConditionExpression: "GSI2PK = :pk",
          ExpressionAttributeValues: {
            ":pk": "USER_STATUS#ACTIVE",
          },
          ScanIndexForward: false, // 新しい順
        })
      );

      if (result.Items) {
        users = result.Items.map((item) => ({
          id: item.UserId,
          name: item.UserName || "",
          imageUrl: item.ImageUrl || "",
          description: item.Description || "",
          emailAddress: item.EmailAddress || "",
        }));
      }
    }

    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify(users),
    };
  } catch (error) {
    console.error("Error fetching users:", error);
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

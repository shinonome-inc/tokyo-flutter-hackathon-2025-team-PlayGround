import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import { GoogleGenerativeAI } from "@google/generative-ai";

interface RequestBody {
  context: string;
}

interface SecretValue {
  gemini_api_key: string;
}

let cachedApiKey: string | null = null;

/**
 * AWS Secrets ManagerからGemini APIキーを取得
 * パフォーマンス向上のためキャッシュを使用
 */
async function getGeminiApiKey(): Promise<string> {
  // キャッシュがあればそれを返す
  if (cachedApiKey) {
    return cachedApiKey;
  }

  const secretArn = process.env.GEMINI_API_KEY_ARN;
  if (!secretArn) {
    throw new Error("GEMINI_API_KEY_ARN environment variable is not set");
  }

  const client = new SecretsManagerClient({ region: process.env.AWS_REGION || "ap-northeast-1" });
  const command = new GetSecretValueCommand({ SecretId: secretArn });

  const response = await client.send(command);
  if (!response.SecretString) {
    throw new Error("Secret value is empty");
  }

  const secret: SecretValue = JSON.parse(response.SecretString);
  if (!secret.gemini_api_key) {
    throw new Error("gemini_api_key not found in secret");
  }

  cachedApiKey = secret.gemini_api_key;
  return cachedApiKey;
}

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    if (!event.body) {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ error: "Request body is required" }),
      };
    }

    const requestBody: RequestBody = JSON.parse(event.body);

    if (!requestBody.context || typeof requestBody.context !== "string") {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          error: "context is required and must be a string",
        }),
      };
    }

    const apiKey = await getGeminiApiKey();

    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-exp" });

    const result = await model.generateContent(requestBody.context);
    const response = result.response;
    const generatedText = response.text();

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        text: generatedText,
      }),
    };
  } catch (error) {
    console.error("Error:", error);
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        error: "Internal server error",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
    };
  }
};

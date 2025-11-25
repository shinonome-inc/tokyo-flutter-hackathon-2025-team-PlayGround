import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from "@aws-sdk/client-secrets-manager";
import { S3Client, PutObjectCommand } from "@aws-sdk/client-s3";
import { GoogleGenerativeAI } from "@google/generative-ai";
import { PredictionServiceClient } from "@google-cloud/aiplatform";
import { v4 as uuidv4 } from "uuid";

interface RequestBody {
  context: string;
  user_id?: string;
  user_name?: string;
}

interface SecretValue {
  gemini_api_key: string;
}

interface Ingredient {
  id: string;
  name: string;
  amount: string;
}

interface Step {
  order_number: number;
  description: string;
}

interface RecipeResponse {
  id: string;
  title: string;
  overview: string;
  image_url: string;
  is_ai_generated: boolean;
  created_at: string;
  user: {
    id: string;
    name: string;
    image_url: string;
    description: string;
    email_address: string;
  };
  notes: string;
  ingredients: Ingredient[];
  steps: Step[];
  comments: any[];
  is_liked_by_me: boolean;
  like_count: number;
}

interface GeneratedRecipe {
  title: string;
  overview: string;
  notes: string;
  ingredients: Array<{ name: string; amount: string }>;
  steps: string[];
}

let cachedApiKey: string | null = null;

/**
 * AWS Secrets ManagerからGemini APIキーを取得
 */
async function getGeminiApiKey(): Promise<string> {
  if (cachedApiKey) {
    return cachedApiKey;
  }

  const secretArn = process.env.GEMINI_API_KEY_ARN;
  if (!secretArn) {
    throw new Error("GEMINI_API_KEY_ARN environment variable is not set");
  }

  const client = new SecretsManagerClient({
    region: process.env.AWS_REGION || "ap-northeast-1",
  });
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

/**
 * S3に画像をアップロード
 */
async function uploadImageToS3(
  imageData: Buffer,
  fileName: string
): Promise<string> {
  const bucketName = process.env.S3_BUCKET_NAME;
  const environment = process.env.ENVIRONMENT || "dev";

  if (!bucketName) {
    throw new Error("S3_BUCKET_NAME environment variable is not set");
  }

  const s3Client = new S3Client({
    region: process.env.AWS_REGION || "ap-northeast-1",
  });
  const key = `${environment}/recipe-images/${fileName}`;

  await s3Client.send(
    new PutObjectCommand({
      Bucket: bucketName,
      Key: key,
      Body: imageData,
      ContentType: "image/png",
    })
  );

  return `https://${bucketName}.s3.ap-northeast-1.amazonaws.com/${key}`;
}

/**
 * Gemini APIでレシピテキストを生成
 */
async function generateRecipeText(
  apiKey: string,
  context: string
): Promise<GeneratedRecipe> {
  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-exp" });

  const prompt = `以下のリクエストに基づいて、料理のレシピを生成してください。
レスポンスは必ず以下のJSON形式で返してください：

{
  "title": "レシピのタイトル",
  "overview": "レシピの概要（2-3文）",
  "notes": "コツやポイント",
  "ingredients": [
    {"name": "材料名", "amount": "分量"}
  ],
  "steps": [
    "手順1の説明",
    "手順2の説明"
  ]
}

リクエスト: ${context}`;

  const result = await model.generateContent(prompt);
  const response = result.response;
  const text = response.text();

  const jsonMatch =
    text.match(/```json\n?([\s\S]*?)\n?```/) || text.match(/(\{[\s\S]*\})/);
  if (!jsonMatch) {
    throw new Error("Failed to extract JSON from response");
  }

  return JSON.parse(jsonMatch[1]);
}

/**
 * Vertex AI Imagen APIで画像を生成
 */
async function generateRecipeImage(recipeTitle: string): Promise<Buffer> {
  const projectId = process.env.GCP_PROJECT_ID || "your-project-id";
  const location = "us-central1";
  const endpoint = `projects/${projectId}/locations/${location}/publishers/google/models/imagegeneration@006`;

  const predictionServiceClient = new PredictionServiceClient({
    apiEndpoint: `${location}-aiplatform.googleapis.com`,
  });

  const prompt = `美味しそうな「${recipeTitle}」の料理写真。プロのフードフォトグラファーが撮影したような、食欲をそそる見た目。`;

  const instanceValue = {
    prompt,
  };
  const instance = {
    structValue: {
      fields: {
        prompt: { stringValue: instanceValue.prompt },
      },
    },
  };

  const parameters = {
    structValue: {
      fields: {
        sampleCount: { numberValue: 1 },
      },
    },
  };

  const request = {
    endpoint,
    instances: [instance],
    parameters,
  };

  const [response] = await predictionServiceClient.predict(request);
  const predictions = response.predictions;

  if (!predictions || predictions.length === 0) {
    throw new Error("No image generated");
  }

  const prediction = predictions[0];
  const imageData =
    prediction.structValue?.fields?.bytesBase64Encoded?.stringValue;

  if (!imageData) {
    throw new Error("Image data not found in response");
  }

  return Buffer.from(imageData, "base64");
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
    const recipe = await generateRecipeText(apiKey, requestBody.context);

    const recipeId = uuidv4();
    const imageBuffer = await generateRecipeImage(recipe.title);
    const imageFileName = `${recipeId}.png`;
    const imageUrl = await uploadImageToS3(imageBuffer, imageFileName);
    const createdAt = new Date().toISOString();
    const userId = requestBody.user_id || "ai-system";
    const userName = requestBody.user_name || "AI Recipe Generator";

    const ingredients: Ingredient[] = recipe.ingredients.map((ing) => ({
      id: uuidv4(),
      name: ing.name,
      amount: ing.amount,
    }));

    const steps: Step[] = recipe.steps.map((step, index) => ({
      order_number: index + 1,
      description: step,
    }));

    const response: RecipeResponse = {
      id: recipeId,
      title: recipe.title,
      overview: recipe.overview,
      image_url: imageUrl,
      is_ai_generated: true,
      created_at: createdAt,
      user: {
        id: userId,
        name: userName,
        image_url: "",
        description: "AI generated recipe",
        email_address: "",
      },
      notes: recipe.notes,
      ingredients,
      steps,
      comments: [],
      is_liked_by_me: false,
      like_count: 0,
    };

    return {
      statusCode: 200,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(response),
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

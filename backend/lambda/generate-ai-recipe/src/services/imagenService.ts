import { PredictionServiceClient } from "@google-cloud/aiplatform";
import { GCP_CONFIG } from "../config/env";
import { createRecipeImagePrompt } from "../utils/promptGenerator";
import { getGcpServiceAccountKey } from "./secretsManagerService";

/**
 * Vertex AI Imagen APIで画像を生成
 */
export async function generateRecipeImage(
  recipeTitle: string,
  ingredients?: Array<{ name: string; amount: string }>,
  overview?: string
): Promise<Buffer> {
  const endpoint = `projects/${GCP_CONFIG.PROJECT_ID}/locations/${GCP_CONFIG.IMAGEN_LOCATION}/publishers/google/models/imagegeneration@006`;

  const credentials = await getGcpServiceAccountKey();

  const predictionServiceClient = new PredictionServiceClient({
    apiEndpoint: `${GCP_CONFIG.IMAGEN_LOCATION}-aiplatform.googleapis.com`,
    credentials,
  });

  const prompt = createRecipeImagePrompt(recipeTitle, ingredients, overview);

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

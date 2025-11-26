import { GoogleGenAI } from "@google/genai";
import { createRecipeImagePrompt } from "../utils/promptGenerator";
import { getGeminiApiKey } from "./secretsManagerService";

/**
 * Gemini APIで画像を生成
 */
export async function generateRecipeImage(
  recipeTitle: string,
  ingredients?: Array<{ name: string; amount: string }>,
  overview?: string
): Promise<Buffer> {
  const apiKey = await getGeminiApiKey();
  const ai = new GoogleGenAI({ apiKey });

  const prompt = createRecipeImagePrompt(recipeTitle, ingredients, overview);

  const response = await ai.models.generateContent({
    model: "gemini-2.5-flash-image-preview",
    contents: prompt,
  });

  const candidates = response.candidates;
  if (!candidates || candidates.length === 0) {
    throw new Error("No image generated");
  }

  const candidate = candidates[0];
  const parts = candidate.content?.parts;
  if (!parts || parts.length === 0) {
    throw new Error("No parts in response");
  }

  let imageData: string | undefined;
  for (const part of parts) {
    if (part.inlineData?.data) {
      imageData = part.inlineData.data;
      break;
    }
  }

  if (!imageData) {
    throw new Error("Image data not found in response");
  }

  return Buffer.from(imageData, "base64");
}

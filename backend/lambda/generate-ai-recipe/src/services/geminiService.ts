import { GoogleGenerativeAI } from "@google/generative-ai";
import { GeneratedRecipe } from "../types/index";
import { createRecipeGenerationPrompt } from "../utils/promptGenerator";
import { extractJsonFromText } from "../utils/jsonUtils";

/**
 * Gemini APIでレシピテキストを生成
 */
export async function generateRecipeText(
  apiKey: string,
  context: string
): Promise<GeneratedRecipe> {
  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash-exp" });

  const prompt = createRecipeGenerationPrompt(context);
  const result = await model.generateContent(prompt);
  const response = result.response;
  const text = response.text();

  const jsonString = extractJsonFromText(text);
  return JSON.parse(jsonString);
}

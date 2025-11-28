import {
  detectLabeledObjectTextsFromImage,
  detectTextsFromImage,
} from "./visionService";
import { INGREDIENT_LABEL_KEYWORDS } from "../constants/ingredientKeywords";

/**
 * 画像から食材情報を抽出してテキスト情報として返す
 * @param imageBuffer 画像データのBuffer
 * @param originalContext 元のレシピ生成コンテキスト
 * @returns 画像から抽出した食材情報を追加したコンテキスト
 */
export async function enrichRecipeContextWithImageIngredients(
  imageBuffer: Buffer,
  originalContext: string
): Promise<string> {
  const labeledObjectTexts = await detectLabeledObjectTextsFromImage(
    imageBuffer,
    INGREDIENT_LABEL_KEYWORDS
  );
  const detectedTexts = await detectTextsFromImage(imageBuffer);
  const detectedIngredientsText = [
    ...new Set([...labeledObjectTexts, ...detectedTexts]),
  ];

  return detectedIngredientsText.length > 0
    ? originalContext +
        "\n\n画像から検出された食材:\n" +
        detectedIngredientsText.map((ing) => `- ${ing}`).join("\n")
    : originalContext;
}

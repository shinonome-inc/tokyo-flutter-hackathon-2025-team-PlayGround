import {
  detectLabeledObjectTextsFromImage,
  detectTextsFromImage,
} from "./visionService";
import { INGREDIENT_LABEL_KEYWORDS } from "../constants/ingredientKeywords";

/**
 * 画像から食材情報を抽出してテキスト情報として返す
 * @param imageBase64 Base64エンコードされた画像データ
 * @param originalContext 元のレシピ生成コンテキスト
 * @returns 画像から抽出した食材情報を追加したコンテキスト
 */
export async function enrichRecipeContextWithImageIngredients(
  imageBase64: string,
  originalContext: string
): Promise<string> {
  const labeledObjectTexts = await detectLabeledObjectTextsFromImage(
    imageBase64,
    INGREDIENT_LABEL_KEYWORDS
  );
  const detectedTexts = await detectTextsFromImage(imageBase64);
  const detectedIngredientsText = [
    ...new Set([...labeledObjectTexts, ...detectedTexts]),
  ];

  return detectedIngredientsText.length > 0
    ? originalContext +
        "\n\n画像から検出された食材:\n" +
        detectedIngredientsText.map((ing) => `- ${ing}`).join("\n")
    : originalContext;
}

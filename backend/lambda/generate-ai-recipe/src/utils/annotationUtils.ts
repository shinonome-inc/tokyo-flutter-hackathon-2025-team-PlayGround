import { INGREDIENT_LABEL_KEYWORDS } from "../constants/ingredientKeywords";

/**
 * ラベルアノテーションから特定のキーワードに関連するラベルを抽出する
 * @param annotations ラベルアノテーションの配列
 * @param keywords 検索するキーワードリスト
 * @returns 指定されたキーワードに関連するラベルのリスト
 */
export function extractIngredientLabels(
  annotations: Array<{description?: string | null}> | null | undefined,
  keywords: string[] = INGREDIENT_LABEL_KEYWORDS
): string[] {
  if (!annotations) {
    return [];
  }
  return annotations
    .map(label => label.description || '')
    .filter(labelText => {
      return keywords.some(keyword => {
        return labelText.toLowerCase().includes(keyword.toLowerCase());
      });
    })
    .filter(Boolean);
}

/**
 * テキストアノテーションからテキストを抽出する
 * @param annotations テキストアノテーションの配列
 * @returns 抽出されたテキストリスト
 */
export function extractTexts(
  annotations: Array<{description?: string | null}> | null | undefined
): string[] {
  if (!annotations) {
    return [];
  }
  return annotations
    .slice(1)
    .map(text => text.description || '')
    .filter(Boolean);
}
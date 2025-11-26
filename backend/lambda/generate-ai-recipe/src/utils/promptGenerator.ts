/**
 * レシピ生成用のプロンプトを作成
 */
export function createRecipeGenerationPrompt(context: string): string {
  return `以下のリクエストに基づいて、料理のレシピを生成してください。
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
}

/**
 * レシピ画像生成用のプロンプトを作成
 */
export function createRecipeImagePrompt(
  recipeTitle: string,
  ingredients?: Array<{ name: string; amount: string }>,
  overview?: string
): string {
  let prompt = `料理の写真を生成してください。料理のタイトルは「${recipeTitle}」です。`;

  if (ingredients && ingredients.length > 0) {
    const mainIngredients = ingredients.map((ing) => ing.name).join("、");
    prompt += `使用する食材: ${mainIngredients}。`;
  }

  prompt += `お皿に盛り付けられた完成した料理。食べ物の写真。食卓。キッチン。レシピ。`;

  return prompt;
}

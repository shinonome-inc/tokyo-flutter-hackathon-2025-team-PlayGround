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
  let prompt = `A high-quality, appetizing photograph of "${recipeTitle}" dish. `;

  if (ingredients && ingredients.length > 0) {
    const mainIngredients = ingredients
      .slice(0, 3)
      .map((ing) => ing.name)
      .join(", ");
    prompt += `Main ingredients visible: ${mainIngredients}. `;
  }

  if (overview) {
    prompt += `${overview} `;
  }

  prompt += `Professional food photography with natural lighting, shallow depth of field, shot from a 45-degree angle. The dish should look delicious and ready to serve, with vibrant colors and beautiful presentation. Restaurant quality plating on a white plate, slightly angled view. Photorealistic, 4K quality.`;

  return prompt;
}

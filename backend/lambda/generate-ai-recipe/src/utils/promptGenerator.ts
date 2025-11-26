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
export function createRecipeImagePrompt(recipeTitle: string): string {
  return `美味しそうな「${recipeTitle}」の料理写真。プロのフードフォトグラファーが撮影したような、食欲をそそる見た目。`;
}

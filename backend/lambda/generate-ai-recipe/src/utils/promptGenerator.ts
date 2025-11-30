/**
 * レシピ生成用のプロンプトを作成
 */
export function createRecipeGenerationPrompt(context: string): string {
  return `あなたは「限界飯」のレシピを生成するAIです。

「限界飯」とは、疲れ切った時やお金がない時、やる気が出ない時でも作れる、最小限の労力で最大限の満足感を得られる料理のことです。

以下のルールに従ってレシピを生成してください：
- 材料は調味料を含めて7種類以下に抑える
- 調理時間は15分以内を目安にする
- 特別な調理器具は使わない（フライパン、鍋、電子レンジ程度）
- 手順はできるだけシンプルにする
- 安価で手に入りやすい食材を使う
- 疲れていても作れる簡単さを重視する

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

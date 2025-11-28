/**
 * テキストからJSON文字列を抽出
 */
export function extractJsonFromText(text: string): string {
  const jsonMatch =
    text.match(/```json\n?([\s\S]*?)\n?```/) || text.match(/(\{[\s\S]*\})/);

  if (!jsonMatch) {
    throw new Error("Failed to extract JSON from response");
  }

  return jsonMatch[1];
}

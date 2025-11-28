import { extractJsonFromText } from '../src/utils/jsonUtils';

describe('JSONユーティリティ', () => {
  describe('テキストからのJSON抽出', () => {
    it('コードブロックからJSONを抽出する', () => {
      const text = 'テキストの中に ```json\n{"key": "value"}\n```';
      const result = extractJsonFromText(text);
      expect(result).toBe('{"key": "value"}');
    });

    it('改行のないコードブロックからJSONを抽出する', () => {
      const text = 'テキストの中に ```json{"key": "value"}```';
      const result = extractJsonFromText(text);
      expect(result).toBe('{"key": "value"}');
    });

    it('通常のJSONオブジェクトからJSONを抽出する', () => {
      const text = 'テキストの前に {"key": "value"} テキストの後に';
      const result = extractJsonFromText(text);
      expect(result).toBe('{"key": "value"}');
    });

    it('JSONが見つからない場合はエラーをスローする', () => {
      const text = 'JSONはありません';
      expect(() => extractJsonFromText(text)).toThrow('Failed to extract JSON from response');
    });
  });
});
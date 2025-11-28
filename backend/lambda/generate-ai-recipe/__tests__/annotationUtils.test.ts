import { extractIngredientLabels, extractTexts } from '../src/utils/annotationUtils';

describe('アノテーションユーティリティ', () => {
  describe('食材ラベルの抽出', () => {
    it('アノテーションがnullの場合は空の配列を返す', () => {
      expect(extractIngredientLabels(null)).toEqual([]);
    });

    it('アノテーションがundefinedの場合は空の配列を返す', () => {
      expect(extractIngredientLabels(undefined)).toEqual([]);
    });

    it('デフォルトのキーワードに基づいて食材ラベルを抽出する', () => {
      const annotations = [
        { description: 'Tomato' },
        { description: 'キャベツ' },
        { description: 'Fresh ingredient' }
      ];

      const result = extractIngredientLabels(annotations);
      expect(result).toEqual(['キャベツ']);
    });

    it('カスタムキーワードに基づいて食材ラベルを抽出する', () => {
      const annotations = [
        { description: 'Apple' },
        { description: 'Banana' },
        { description: 'Cherry' }
      ];

      const result = extractIngredientLabels(annotations, ['apple', 'cherry']);
      expect(result).toEqual(['Apple', 'Cherry']);
    });
  });

  describe('テキストの抽出', () => {
    it('アノテーションがnullの場合は空の配列を返す', () => {
      expect(extractTexts(null)).toEqual([]);
    });

    it('アノテーションがundefinedの場合は空の配列を返す', () => {
      expect(extractTexts(undefined)).toEqual([]);
    });

    it('最初のアノテーションを除いたテキストを抽出する', () => {
      const annotations = [
        { description: '最初のアノテーション' },
        { description: '2番目のテキスト' },
        { description: '3番目のテキスト' }
      ];

      const result = extractTexts(annotations);
      expect(result).toEqual(['2番目のテキスト', '3番目のテキスト']);
    });

    it('空の説明を除外する', () => {
      const annotations = [
        { description: '最初のアノテーション' },
        { description: '' },
        { description: '3番目のテキスト' },
        { description: null }
      ];

      const result = extractTexts(annotations);
      expect(result).toEqual(['3番目のテキスト']);
    });
  });
});
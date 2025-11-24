# バックエンド

バックエンド用のリポジトリ。
AWS Lambda 関数を管理。

## ディレクトリ構造

```
backend/
├── README.md
└── lambda/                 # AWS Lambda
    ├── package.json        # プロジェクト依存関係
    ├── tsconfig.json       # TypeScriptコンパイラ設定
    └── xxx/                # 各エンドポイントごとのLambda関数
        └── src/            # ソースコード
            └── index.ts    # Lambda関数のエントリーポイント
```

## 環境

- Node.js 20.x
- TypeScript
- AWS Lambda

## セットアップ

詳細なセットアップ手順については、[`docs/GET_STARTED.md`](../docs/GET_STARTED.md) を参照してください。

## コマンド

- `npm run build`: TypeScript をコンパイル
- `npm test`: テストを実行（未実装）

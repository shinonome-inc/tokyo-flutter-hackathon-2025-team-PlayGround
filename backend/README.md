# バックエンド

バックエンド用のリポジトリ。
AWS Lambda 関数を管理。

## ディレクトリ構造

```
backend/
├── README.md              # このファイル
└── lambda/                 # AWS Lambda関数
    ├── dist/               # デプロイ用ZIPファイル出力ディレクトリ
    ├── package.json        # プロジェクト依存関係と共通スクリプト
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

`backend/lambda/` にて実行してください。

### 特定の Lambda 関数をビルドし、ZIP パッケージを作成

```bash
npm run build:package -w @genkaimeshi/generate-ai-recipe
```

### 全ての Lambda 関数をビルドし、ZIP パッケージを作成

```bash
npm run build:package --workspaces
```

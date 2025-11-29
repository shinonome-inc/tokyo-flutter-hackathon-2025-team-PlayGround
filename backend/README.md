# バックエンド

バックエンド用のリポジトリ。
AWS Lambda 関数を管理。

## ディレクトリ構造

```
backend/
├── README.md                # このファイル
└── lambda/
    ├── dist/                # デプロイ用ZIPファイル出力ディレクトリ
    ├── package.json         # 共通の依存関係（typescript, jest, @aws-sdk等）
    ├── tsconfig.json        # 共通のTypeScript設定
    ├── jest.config.js       # 共通のJest設定
    ├── scripts/
    │   └── package.sh       # Lambda関数のビルド・パッケージングスクリプト
    ├── generate-ai-recipe/  # AI レシピ生成 Lambda
    ├── presigned-url/       # S3 presigned URL 生成 Lambda
    ├── get-recipes/         # レシピ一覧取得 Lambda (GET /recipes)
    └── post_recipe/         # レシピ投稿 Lambda (POST /recipes)
```

各 Lambda 関数のディレクトリ構造:

```
xxx/
├── package.json        # エンドポイント固有の依存関係とスクリプト
├── tsconfig.json       # 親のtsconfig.jsonを継承
└── src/
    └── index.ts        # Lambda関数のエントリーポイント
```

## 環境

- Node.js 20.x
- TypeScript
- AWS Lambda

## セットアップ

詳細なセットアップ手順については、[`docs/GET_STARTED.md`](../docs/GET_STARTED.md) を参照してください。

## コマンド

**注意**: 全てのコマンドはプロジェクトルートから実行してください。

### 依存関係のインストール

```bash
npm install
```

### 特定の Lambda 関数をビルド & ZIP パッケージを作成

```bash
npm run package -w @genkaimeshi/generate-ai-recipe
```

### 全ての Lambda 関数をビルド & ZIP パッケージを作成

```bash
npm run lambda:package
```

### テストを実行

```bash
npm test
```

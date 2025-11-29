# AI Recipe Generator API

画像から食材を検出し、AI を使ってレシピを自動生成する Lambda 関数です。

## 概要

この API は以下の機能を提供します：

1. S3 にアップロードされた画像から食材を検出（Google Cloud Vision API 使用）
2. 検出された食材とユーザーのコンテキストを元にレシピを生成（Gemini API 使用）
3. 生成されたレシピに基づいた画像を生成（Imagen API 使用）
4. 生成した画像を S3 にアップロードして URL を返却

## API 使用フロー

### 1. Presigned URL の取得

まず、画像を S3 にアップロードするための Presigned URL を取得します。

**エンドポイント:** `POST /v1/presigned-url`

**リクエスト:**

```bash
curl -X POST https://{api-gateway-url}/dev/v1/presigned-url
```

**レスポンス:**

```json
{
  "upload_url": "https://genkaimeshi-recipe-recipe-images.s3.ap-northeast-1.amazonaws.com/dev/recipe-images/abc-123.png?X-Amz-Algorithm=...",
  "file_name": "abc-123.png"
}
```

### 2. 画像を S3 にアップロード

取得した Presigned URL に対して、画像ファイルを PUT リクエストでアップロードします。
curl の代わりに Postman などのツールを使ってもできます。

**リクエスト:**

```bash
curl -X PUT "{upload_url}" \
  -H "Content-Type: image/png" \
  --data-binary @your-image.png
```

**注意:**

- `upload_url`は手順 1 で取得した URL をそのまま使用
- `Content-Type`は`image/png`を指定
- API Gateway 経由ではなく、**直接 S3 へのアップロード**

### 3. レシピ生成 API の呼び出し

画像のアップロードが完了したら、`file_name`を使ってレシピ生成 API を呼び出します。

**エンドポイント:** `POST /v1/generate-recipe`

**リクエストボディ:**

```json
{
  "prompt": "この食材で作れるレシピを提案して。",
  "userId": "user123",
  "imageS3Key": "abc-123.png",
  "userName": "山田太郎"
}
```

**パラメータ:**

- `prompt` (必須): AIへのプロンプト（例: "簡単に作れるレシピを提案して"）
- `userId` (必須): レシピを作成するユーザーの ID
- `imageS3Key` (オプション): 手順 1 で取得した`file_name`
- `userName` (オプション): ユーザー名（デフォルト: "AI Recipe Generator"）

**cURL の例:**

```bash
curl -X POST https://{api-gateway-url}/dev/v1/generate-recipe \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "この食材で作れるレシピを提案して。",
    "userId": "user123",
    "imageS3Key": "abc-123.png"
  }'
```

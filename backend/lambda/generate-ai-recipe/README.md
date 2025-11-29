# AI Recipe Generator API

画像から食材を検出し、AI を使ってレシピを自動生成する Lambda 関数です。

## 概要

この API は以下の機能を提供します：

1. S3 にアップロードされた画像から食材を検出（Google Cloud Vision API 使用）
2. 検出された食材とユーザーのプロンプトを元にレシピを生成（Gemini API 使用）
3. 生成されたレシピに基づいた画像を生成（Imagen API 使用）
4. 生成した画像を S3 にアップロードして URL を返却
5. 生成したレシピを DynamoDB に保存

## API 使用フロー

**エンドポイント:** `POST /v1/generate-recipe`

**認証:** Authorization ヘッダーに Bearer トークンが必要です。ユーザー ID はトークンから自動的に取得されます。

### パターン A: 画像なしでレシピ生成（1 ステップ）

画像を使わずにテキストプロンプトのみでレシピを生成する場合。

```bash
curl -X POST https://{api-gateway-url}/dev/v1/generate-recipe \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {your-jwt-token}" \
  -d '{
    "prompt": "カレーのレシピを提案して"
  }'
```

### パターン B: 画像付きでレシピ生成（2 ステップ）

食材の画像を使ってレシピを生成する場合。

#### ステップ 1: Presigned URL の取得

```bash
curl -X POST https://{api-gateway-url}/dev/v1/generate-recipe \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {your-jwt-token}" \
  -d '{
    "prompt": "この食材で作れるレシピを提案して",
    "requiresImageUpload": true
  }'
```

**レスポンス:**

```json
{
  "uploadUrl": "https://genkaimeshi-recipe-recipe-images.s3.ap-northeast-1.amazonaws.com/dev/recipe-images/abc-123.png?X-Amz-Algorithm=...",
  "imageS3Key": "abc-123.png"
}
```

取得した `uploadUrl` に対して、画像ファイルを PUT リクエストでアップロードします。

```bash
curl -X PUT "{uploadUrl}" \
  -H "Content-Type: image/png" \
  --data-binary @your-image.png
```

#### ステップ 2: レシピ生成

画像のアップロードが完了したら、`imageS3Key` を使ってレシピ生成 API を呼び出します。

```bash
curl -X POST https://{api-gateway-url}/dev/v1/generate-recipe \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {your-jwt-token}" \
  -d '{
    "prompt": "この食材で作れるレシピを提案して",
    "imageS3Key": "abc-123.png"
  }'
```

## リクエストパラメータ

| パラメータ           | 必須 | 説明                                                                 |
| -------------------- | ---- | -------------------------------------------------------------------- |
| `prompt`             | ○    | AI へのプロンプト（例: "簡単に作れるレシピを提案して"）              |
| `imageS3Key`         | -    | S3 にアップロードした画像のキー                                      |
| `requiresImageUpload`| -    | `true` を指定すると、presigned URL を返却するモードになる            |

## 認証

Authorization ヘッダーに JWT トークンを含める必要があります。ユーザー ID はトークンの `sub` クレームから自動的に取得されます。

```
Authorization: Bearer {your-jwt-token}
```

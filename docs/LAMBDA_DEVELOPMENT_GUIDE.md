# Lambda関数開発ガイド

## 新しいLambda関数を追加する際のチェックリスト

新しいLambda関数を追加する場合、以下の全ての手順を実行すること。

### 1. Lambda関数のソースコード作成

`backend/lambda/{function-name}/` ディレクトリを作成し、以下のファイルを配置する。

```
backend/lambda/{function-name}/
├── src/
│   └── index.ts        # Lambda関数の実装
├── __tests__/
│   └── handler.test.ts # テストファイル
├── package.json        # 依存関係定義
└── tsconfig.json       # TypeScript設定
```

**注意**: `jest.config.js` は各Lambda関数ディレクトリには作成しないこと。テスト設定は `backend/lambda/jest.config.js` で一元管理されている。

#### package.json の例

```json
{
  "name": "@genkaimeshi/{function-name}",
  "version": "1.0.0",
  "private": true,
  "engines": {
    "node": ">=20.0.0"
  },
  "scripts": {
    "build": "tsc -p .",
    "package": "../scripts/package.sh {function-name} {output_zip_name}.zip @aws-sdk @smithy",
    "build:package": "npm run package"
  },
  "dependencies": {
    "@aws-sdk/client-dynamodb": "^3.705.0",
    "@aws-sdk/lib-dynamodb": "^3.705.0"
  }
}
```

#### tsconfig.json の例

```json
{
  "extends": "../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

**重要**: `rootDir` を必ず `"./src"` に設定すること。これがないと、ビルド時に `dist/src/index.js` のようなネストした構造になり、Lambdaが `Cannot find module 'index'` エラーで起動しなくなる。

### 2. ルートの package.json に workspace を追加

**重要**: この手順を忘れるとCIでビルドが失敗する。

`/package.json` の `workspaces` 配列に新しいLambda関数のパスを追加する。

```json
{
  "workspaces": [
    "backend/lambda",
    "backend/lambda/generate-ai-recipe",
    "backend/lambda/presigned-url",
    "backend/lambda/get-recipes",
    "backend/lambda/get-recipe-by-id",  // ← 追加
    "backend/lambda/post_recipe"
  ]
}
```

**重要**: workspace追加後、ルートディレクトリで `npm install` を実行して `package-lock.json` を更新すること。

```bash
cd /path/to/project-root
npm install
```

これを忘れると `npm ci` 実行時に以下のエラーが発生する：
```
npm error `npm ci` can only install packages when your package.json and package-lock.json are in sync.
npm error Missing: @genkaimeshi/{function-name}@1.0.0 from lock file
```

### 3. Terraform設定の追加（dev環境）

以下の3ファイルを編集する。

#### infra/aws/dev/lambda.tf

```hcl
resource "aws_lambda_function" "{function_name}" {
  function_name = "${var.project_name}-{function-name}"
  role          = aws_iam_role.lambda_execution_role.arn

  runtime = "nodejs20.x"
  handler = "index.handler"

  filename         = "../../../backend/lambda/dist/{output_zip_name}.zip"
  source_code_hash = filebase64sha256("../../../backend/lambda/dist/{output_zip_name}.zip")

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.main_table.name
      ENVIRONMENT         = "dev"
    }
  }

  timeout     = 10
  memory_size = 128

  depends_on = [aws_cloudwatch_log_group.{function_name}_lambda_log_group]
}

resource "aws_lambda_permission" "api_gateway_{function_name}_lambda" {
  statement_id  = "AllowAPIGatewayInvoke{FunctionName}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.{function_name}.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.main_api.execution_arn}/*/*"
}
```

#### infra/aws/dev/cloudwatch.tf

```hcl
resource "aws_cloudwatch_log_group" "{function_name}_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-{function-name}"
  retention_in_days = 14
}
```

#### infra/aws/dev/api_gateway.tf

API Gatewayのリソース、メソッド、統合、CORS設定を追加する。

**重要**: 各HTTPメソッド（GET/POST/OPTIONS）に対して、以下の4つのリソースが必要：

1. `aws_api_gateway_method` - メソッド定義
2. `aws_api_gateway_integration` - Lambda統合
3. `aws_api_gateway_method_response` - レスポンス定義（CORSヘッダー許可）
4. `aws_api_gateway_integration_response` - レスポンス値設定（CORSヘッダー値）

```hcl
# 例: GET /recipes/{recipeId} の場合

# 1. メソッド
resource "aws_api_gateway_method" "recipe_by_id_get_method" {
  rest_api_id   = aws_api_gateway_rest_api.main_api.id
  resource_id   = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# 2. Lambda統合
resource "aws_api_gateway_integration" "recipe_by_id_get_integration" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method = aws_api_gateway_method.recipe_by_id_get_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_recipe_by_id.invoke_arn
}

# 3. メソッドレスポンス（CORSヘッダーを許可）
resource "aws_api_gateway_method_response" "recipe_by_id_get_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method = aws_api_gateway_method.recipe_by_id_get_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# 4. 統合レスポンス（CORSヘッダー値を設定）
resource "aws_api_gateway_integration_response" "recipe_by_id_get_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.main_api.id
  resource_id = aws_api_gateway_resource.recipe_by_id_resource.id
  http_method = aws_api_gateway_method.recipe_by_id_get_method.http_method
  status_code = aws_api_gateway_method_response.recipe_by_id_get_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.recipe_by_id_get_integration]
}
```

また、`aws_api_gateway_deployment` の `depends_on` に新しいintegrationとintegration_responseを追加する。

### 4. Terraform設定の追加（prod環境）

dev環境と同様に、以下のファイルを編集する。

- `infra/aws/prod/lambda.tf`
- `infra/aws/prod/cloudwatch.tf`
- `infra/aws/prod/api_gateway.tf`

**注意**: `ENVIRONMENT` 変数は `"prod"` に設定すること。

### 5. ビルドとテストの確認

```bash
# Lambda関数のビルド
cd backend/lambda/{function-name}
npm run build

# テスト実行
cd backend/lambda
npm test -- --testPathPattern="{function-name}"

# パッケージ作成（CI用）
cd /path/to/project-root
npm ci
npm run lambda:package
```

### 6. Terraform検証

```bash
cd infra/aws/dev
terraform init
terraform validate
terraform plan
```

## ディレクトリ構造

```
backend/lambda/
├── dist/                    # ビルド成果物（.zipファイル）
├── node_modules/
├── scripts/
│   └── package.sh           # パッケージングスクリプト
├── generate-ai-recipe/
├── presigned-url/
├── get-recipes/
├── get-recipe-by-id/
├── post_recipe/
├── jest.config.js
├── package.json
└── tsconfig.json
```

## DynamoDBシングルテーブル設計

### キー設計

| Entity | PK | SK |
|--------|----|----|
| Recipe | `RECIPE#{recipeId}` | `RECIPE#{recipeId}` |
| Ingredient | `RECIPE#{recipeId}` | `INGREDIENT#{order}#{ingredientId}` |
| Step | `RECIPE#{recipeId}` | `STEP#{order}#{stepId}` |
| User | `USER#{userId}` | `PROFILE` |

### GSI

| GSI | PK | SK | 用途 |
|-----|----|----|------|
| GSI1 | `USER#{userId}` | `RECIPE#{createdAt}` | ユーザーのレシピ一覧 |
| GSI2 | `RECIPE_STATUS#PUB` | `{createdAt}` | タイムライン（新着順） |
| GSI3 | - | - | 予備 |

## よくあるミス

1. **workspaceの追加忘れ** - CIでzipファイルが生成されずTerraform validateが失敗する
2. **package-lock.jsonの更新忘れ** - workspace追加後に`npm install`を実行しないと`npm ci`が失敗する
3. **tsconfig.jsonのrootDir設定忘れ** - `rootDir: "./src"`がないとLambdaが`Cannot find module 'index'`で起動しない
4. **method_response/integration_responseの追加忘れ** - CORSエラーが発生する（OPTIONSだけでなく本リクエスト用も必要）
5. **depends_onの追加忘れ** - API Gatewayのデプロイで依存関係エラーが発生する
6. **prod環境の設定忘れ** - dev環境のみ設定してprod環境を忘れる
7. **CloudWatch Log Groupの追加忘れ** - Lambda関数の起動時にエラーが発生する
8. **API Gatewayの再デプロイ忘れ** - Terraform apply後、変更が反映されない場合は手動で再デプロイが必要な場合がある
9. **個別Lambda関数へのjest.config.js追加** - 各Lambda関数ディレクトリには`jest.config.js`を作成しないこと。テスト設定は`backend/lambda/jest.config.js`で一元管理されており、個別に作成すると不整合が発生する

### API Gateway再デプロイ方法

```bash
# API IDを確認
aws apigateway get-rest-apis --region ap-northeast-1

# 再デプロイ
aws apigateway create-deployment --rest-api-id <api-id> --stage-name dev --region ap-northeast-1
```

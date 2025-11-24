# GET STARTED

開発環境のセットアップガイド

---

## 1. Terraform 環境のセットアップ

### 1-1. 前提条件

- Terraform がインストールされていること (v1.5.0 以上)
- AWS CLI がインストールされていること（AWS 環境用）
- Google Cloud CLI (`gcloud`) がインストールされていること（GCP 環境用）
- `terraform-aws-key.json` が手元にあること（AWS 認証用）
- `terraform-gcp-key.json` が手元にあること（GCP 認証用）

### 1-2. 環境変数設定時の注意事項

**重要**: AWS・GCP 両方の認証設定で、`~/.zshrc`や`~/.bashrc`に環境変数を追記した後は、以下のいずれかが必要です：

- **現在のターミナルで反映**: `source ~/.zshrc` を実行
- **新しいターミナルを開く**: 自動的に読み込まれます

**環境変数が設定されていないと Terraform が失敗します**ので、設定後は必ず確認コマンドで確認してください。

### 1-3. AWS 認証の設定

#### 認証キーの配置

`terraform-aws-key.json` を `infra/` 直下に配置：

```bash
cp terraform-aws-key.json infra/terraform-aws-key.json
```

#### 環境変数の設定

`infra/terraform-aws-key.json` の内容を確認：

```json
{
    "AccessKey": {
        "UserName": "terraform-iam-user",
        "AccessKeyId": "AKIA...",
        "SecretAccessKey": "...",
        ...
    }
}
```

`~/.zshrc` または `~/.bashrc` に追記（AccessKeyId と SecretAccessKey は上記 JSON ファイルから取得）：

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="ap-northeast-1"
```

設定を反映（**1-2 の注意事項参照**）：

```bash
source ~/.zshrc
```

確認：

```bash
aws sts get-caller-identity
```

期待される出力：

```json
{
  "UserId": "AIDA...",
  "Account": "851725222522",
  "Arn": "arn:aws:iam::851725222522:user/terraform-iam-user"
}
```

### 1-4. GCP 認証の設定

#### 認証キーの配置

`terraform-gcp-key.json` を `infra/` 直下に配置：

```bash
cp terraform-gcp-key.json infra/terraform-gcp-key.json
```

#### 環境変数の設定

`~/.zshrc` または `~/.bashrc` に追記：

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/project/infra/terraform-gcp-key.json"
```

設定を反映（**1-2 の注意事項参照**）：

```bash
source ~/.zshrc
```

確認：

```bash
echo $GOOGLE_APPLICATION_CREDENTIALS
```

### 1-5. terraform.tfvars の配置

**重要**: `.gitignore` で `*.tfvars` が除外されているため、CI/CD と同じく、ローカル環境でも `terraform.tfvars` を手動で配置する必要があります。

#### AWS dev 環境

```bash
# infra/aws/dev/terraform.tfvars を作成
cat > infra/aws/dev/terraform.tfvars << 'EOF'
google_client_id     = "YOUR_GOOGLE_CLIENT_ID"
google_client_secret = "YOUR_GOOGLE_CLIENT_SECRET"
line_channel_id      = "YOUR_LINE_CHANNEL_ID"
line_channel_secret  = "YOUR_LINE_CHANNEL_SECRET"
EOF
```

#### AWS prod 環境

```bash
# infra/aws/prod/terraform.tfvars を作成
cat > infra/aws/prod/terraform.tfvars << 'EOF'
google_client_id     = "YOUR_GOOGLE_CLIENT_ID"
google_client_secret = "YOUR_GOOGLE_CLIENT_SECRET"
line_channel_id      = "YOUR_LINE_CHANNEL_ID"
line_channel_secret  = "YOUR_LINE_CHANNEL_SECRET"
EOF
```

**注意**: GCP 環境はデフォルト値で全て動作するため、`terraform.tfvars` の作成は不要です。

### 1-6. CI/CD での設定

GitHub Actions で Terraform CI を実行する際には、以下の Secrets をリポジトリに登録してください：

- `TF_VARS_AWS_DEV` - AWS dev 環境用の `terraform.tfvars` 全体の内容
- `TF_VARS_AWS_PROD` - AWS prod 環境用の `terraform.tfvars` 全体の内容

### 1-7. Terraform 実行

#### AWS dev 環境

```bash
cd infra/aws/dev
terraform init
terraform plan
terraform apply
```

#### AWS prod 環境

```bash
cd infra/aws/prod
terraform init
terraform plan
terraform apply
```

#### GCP dev 環境

```bash
cd infra/gcp/dev
terraform init
terraform plan
terraform apply
```

#### GCP prod 環境

```bash
cd infra/gcp/prod
terraform init
terraform plan
terraform apply
```

---

## 2. Flutter 環境のセットアップ

### 2-1. 前提条件

- Flutter がインストールされていること
- FVM (Flutter Version Manager) がインストールされていること

### 2-2. Flutter バージョンの準備

このプロジェクトは `app/.fvmrc` で Flutter バージョンを指定しています：

```bash
cd app
fvm install
fvm use
```

### 2-3. 依存パッケージの取得

```bash
cd app
fvm flutter pub get
```

### 2-4. アプリケーションの実行

```bash
# dev 環境で実行（デフォルト）
fvm flutter run

# prod 環境で実行
fvm flutter run --dart-define=ENV=prod
```

### 2-5. 静的解析

```bash
fvm flutter analyze
fvm dart run custom_lint
```

### 2-6. テスト実行

```bash
fvm flutter test
```

### 2-7. Code Generation (今後追加予定)

```bash
# build_runner での自動生成処理（実装予定）
# fvm dart run build_runner build
```

---

## 3. バックエンド環境のセットアップ

### 3-1. 前提条件

- Node.js 20.x 以上がインストールされていること
- npm (Node Package Manager) がインストールされていること

### 3-2. プロジェクト依存関係のインストール

**注意**: 以下のコマンドは `backend/lambda/` ディレクトリで実行します。

```bash
npm install
```

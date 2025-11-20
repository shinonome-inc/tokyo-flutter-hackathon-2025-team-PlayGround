# GET STARTED

開発環境のセットアップガイド

---

## 1. Terraform環境のセットアップ

### 1-1. 前提条件

- Terraform がインストールされていること (v1.5.0以上)
- AWS CLI がインストールされていること（AWS環境用）
- Google Cloud CLI (`gcloud`) がインストールされていること（GCP環境用）
- `terraform-aws-key.json` が手元にあること（AWS認証用）
- `terraform-gcp-key.json` が手元にあること（GCP認証用）

### 1-2. AWS認証の設定

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

`~/.zshrc` または `~/.bashrc` に追記（AccessKeyIdとSecretAccessKeyは上記JSONファイルから取得）：

```bash
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="ap-northeast-1"
```

設定を反映：

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

### 1-3. GCP認証の設定

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

設定を反映：

```bash
source ~/.zshrc
```

確認：

```bash
echo $GOOGLE_APPLICATION_CREDENTIALS
```

### 1-4. Terraform実行

#### AWS dev環境

```bash
cd infra/aws/dev
terraform init
terraform plan
terraform apply
```

#### GCP dev環境

```bash
cd infra/gcp/dev
terraform init
terraform plan
terraform apply
```

---

## 2. Flutter環境のセットアップ

(TODO: 追加予定)

---

## 3. バックエンド環境のセットアップ

(TODO: 追加予定)

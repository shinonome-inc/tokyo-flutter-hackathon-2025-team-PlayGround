# GET STARTED

開発環境のセットアップガイド

---

## 1. Terraform環境のセットアップ

### 1-1. 前提条件

- AWS CLI がインストールされていること
- Terraform がインストールされていること (v1.5.0以上)
- `terraform-iam-user.json` が手元にあること

### 1-2. Terraform実行用IAMユーザーの設定

#### アクセスキーの確認

`terraform-iam-user.json` の内容を確認：

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

#### AWS CLIプロファイル設定

```bash
aws configure --profile terraform
```

入力内容：
- **AWS Access Key ID**: `terraform-iam-user.json` の `AccessKeyId` をコピペ
- **AWS Secret Access Key**: `terraform-iam-user.json` の `SecretAccessKey` をコピペ
- **Default region name**: `ap-northeast-1`
- **Default output format**: `json`

#### 設定確認

```bash
aws sts get-caller-identity --profile terraform
```

期待される出力：
```json
{
    "UserId": "AIDA...",
    "Account": "851725222522",
    "Arn": "arn:aws:iam::851725222522:user/terraform-iam-user"
}
```

### 1-3. Terraform実行時の設定

環境変数で指定：

```bash
export AWS_PROFILE=terraform
```

確認：
```bash
echo $AWS_PROFILE
# 出力: terraform
```

### 1-4. Terraform実行

dev環境の例：

```bash
cd infra/terraform/environments/dev
export AWS_PROFILE=terraform
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

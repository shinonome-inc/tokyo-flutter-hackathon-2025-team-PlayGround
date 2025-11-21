# インフラストラクチャ構成

このディレクトリには、AWS・GCP のインフラストラクチャを Terraform で管理するための設定が含まれています。

## ディレクトリ構造

```
infra/
├── README.md                  # このファイル
├── terraform-aws-key.json     # AWS認証キー（gitignore対象）
├── terraform-gcp-key.json     # GCP認証キー（gitignore対象）
├── aws/                       # AWS環境
│   ├── dev/                   # 開発環境
│   │   ├── providers.tf
│   │   ├── versions.tf
│   │   ├── variables.tf
│   │   ├── remote-state.tf
│   │   └── services/          # 各種サービス定義
│   └── prod/                  # 本番環境
│       ├── providers.tf
│       ├── versions.tf
│       ├── variables.tf
│       ├── remote-state.tf
│       └── services/          # 各種サービス定義
└── gcp/                       # GCP環境
    ├── dev/                   # 開発環境
    │   ├── providers.tf
    │   ├── versions.tf
    │   ├── variables.tf
    │   ├── remote-state.tf
    │   └── services/          # 各種サービス定義
    └── prod/                  # 本番環境
        ├── providers.tf
        ├── versions.tf
        ├── variables.tf
        ├── remote-state.tf
        └── services/          # 各種サービス定義
```

## セットアップ手順

[`docs/GET_STARTED.md`](../docs/GET_STARTED.md) を参照してください。

## Terraform バックエンド

Terraform State は、AWS S3 と DynamoDB で管理されています：

- **S3 バケット**: `genkaimeshi-recipe-terraform-state`
- **DynamoDB テーブル**: `terraform-lock`
- **リージョン**: `ap-northeast-1`

### State ファイルのパス

- `aws/dev/terraform.tfstate`
- `aws/prod/terraform.tfstate`
- `gcp/dev/terraform.tfstate`
- `gcp/prod/terraform.tfstate`

## 新しいサービスの追加方法

各環境の `services/` ディレクトリ内に、サービスごとの Terraform ファイルを作成してください。

例：

```bash
# AWSでS3を追加する場合
infra/aws/dev/services/s3.tf
infra/aws/prod/services/s3.tf

# GCPでCloud Storageを追加する場合
infra/gcp/dev/services/storage.tf
infra/gcp/prod/services/storage.tf
```

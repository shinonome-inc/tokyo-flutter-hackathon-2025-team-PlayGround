# インフラストラクチャ構成

このディレクトリには、AWS・GCPのインフラストラクチャをTerraformで管理するための設定が含まれています。

## ディレクトリ構造

```
infra/
├── README.md                  # このファイル
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

## Terraformバックエンド

Terraform Stateは、AWS S3とDynamoDBで管理されています：

- **S3バケット**: `genkaimeshi-recipe-terraform-state`
- **DynamoDBテーブル**: `terraform-lock`
- **リージョン**: `ap-northeast-1`

### Stateファイルのパス

- `aws/dev/terraform.tfstate`
- `aws/prod/terraform.tfstate`
- `gcp/dev/terraform.tfstate`
- `gcp/prod/terraform.tfstate`


## 新しいサービスの追加方法

各環境の `services/` ディレクトリ内に、サービスごとのTerraformファイルを作成してください。

例：

```bash
# AWSでS3を追加する場合
infra/aws/dev/services/s3.tf
infra/aws/prod/services/s3.tf

# GCPでCloud Storageを追加する場合
infra/gcp/dev/services/storage.tf
infra/gcp/prod/services/storage.tf
```
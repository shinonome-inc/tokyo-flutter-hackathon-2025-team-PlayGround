resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-prod-user-pool"

  # LINEログインなどemail取得不可のプロバイダー対応のため、emailを必須にしない
  auto_verified_attributes = ["email"]

  mfa_configuration = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "[${var.project_name}] 認証コード"
    email_message        = "認証コードは {####} です。"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    required                 = false
    mutable                  = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "openid email profile"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
    name     = "name"
  }
}

resource "aws_cognito_identity_provider" "line" {
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "LINE"
  provider_type = "OIDC"

  provider_details = {
    client_id                     = var.line_channel_id
    client_secret                 = var.line_channel_secret
    authorize_scopes              = "openid profile"
    oidc_issuer                   = "https://access.line.me"
    authorize_url                 = "https://access.line.me/oauth2/v2.1/authorize"
    token_url                     = "https://api.line.me/oauth2/v2.1/token"
    attributes_url                = "https://api.line.me/v2/profile"
    attributes_url_add_attributes = "false"
    attributes_request_method     = "GET"
  }

  attribute_mapping = {
    username = "sub"
    name     = "name"
  }
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.project_name}-prod-auth"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_user_pool_client" "app" {
  name         = "${var.project_name}-prod-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  supported_identity_providers = [
    "COGNITO",
    aws_cognito_identity_provider.google.provider_name,
    aws_cognito_identity_provider.line.provider_name
  ]

  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid", "email", "profile"]

  callback_urls = var.cognito_callback_urls
  logout_urls   = var.cognito_logout_urls

  prevent_user_existence_errors = "ENABLED"

  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

output "cognito_user_pool_id" {
  value = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_client_id" {
  value = aws_cognito_user_pool_client.app.id
}

output "cognito_domain" {
  value = aws_cognito_user_pool_domain.main.domain
}

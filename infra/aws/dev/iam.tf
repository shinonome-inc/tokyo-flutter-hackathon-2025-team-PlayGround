resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_execution_role.name
}

resource "aws_iam_role_policy" "lambda_secrets_manager_policy" {
  name = "${var.project_name}-lambda-secrets-manager-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.gemini_api_key.arn,
          aws_secretsmanager_secret.gcp_service_account_key.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.secrets_encryption.arn
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name = "${var.project_name}-lambda-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.recipe_images.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.recipe_images.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "${var.project_name}-lambda-dynamodb-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          aws_dynamodb_table.main_table.arn,
          "${aws_dynamodb_table.main_table.arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attach" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

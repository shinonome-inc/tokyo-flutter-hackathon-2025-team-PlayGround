locals {
  recipe_ai_generator_zip = fileexists("../../../backend/lambda/dist/recipe_ai_generator.zip") ?
    "../../../backend/lambda/dist/recipe_ai_generator.zip" :
    "/home/runner/work/tokyo-flutter-hackathon-2025-team-PlayGround/tokyo-flutter-hackathon-2025-team-PlayGround/backend/lambda/dist/recipe_ai_generator.zip"

  presigned_url_zip = fileexists("../../../backend/lambda/dist/presigned_url.zip") ?
    "../../../backend/lambda/dist/presigned_url.zip" :
    "/home/runner/work/tokyo-flutter-hackathon-2025-team-PlayGround/tokyo-flutter-hackathon-2025-team-PlayGround/backend/lambda/dist/presigned_url.zip"
}

resource "aws_lambda_function" "recipe_ai_generator" {
  function_name = "${var.project_name}-recipe-ai-generator"
  role          = aws_iam_role.lambda_execution_role.arn

  runtime = "nodejs20.x"
  handler = "index.handler"

  filename         = local.recipe_ai_generator_zip
  source_code_hash = filebase64sha256(local.recipe_ai_generator_zip)

  environment {
    variables = {
      GEMINI_API_KEY_ARN         = aws_secretsmanager_secret.gemini_api_key.arn
      GCP_SERVICE_ACCOUNT_KEY_ARN = aws_secretsmanager_secret.gcp_service_account_key.arn
      S3_BUCKET_NAME              = aws_s3_bucket.recipe_images.bucket
      ENVIRONMENT                 = "dev"
      GCP_PROJECT_ID              = var.gcp_project_id
    }
  }

  timeout     = 30
  memory_size = 256

  depends_on = [aws_cloudwatch_log_group.recipe_ai_lambda_log_group]
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.recipe_ai_generator.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.main_api.execution_arn}/*/*"
}

resource "aws_lambda_function" "presigned_url_generator" {
  function_name = "${var.project_name}-presigned-url-generator"
  role          = aws_iam_role.lambda_execution_role.arn

  runtime = "nodejs20.x"
  handler = "index.handler"

  filename         = local.presigned_url_zip
  source_code_hash = filebase64sha256(local.presigned_url_zip)

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.recipe_images.bucket
      ENVIRONMENT    = "dev"
    }
  }

  timeout     = 10
  memory_size = 128

  depends_on = [aws_cloudwatch_log_group.presigned_url_lambda_log_group]
}

resource "aws_lambda_permission" "api_gateway_presigned_url_lambda" {
  statement_id  = "AllowAPIGatewayInvokePresignedUrl"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.presigned_url_generator.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.main_api.execution_arn}/*/*"
}
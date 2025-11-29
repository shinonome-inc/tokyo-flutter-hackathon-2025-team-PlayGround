resource "aws_lambda_function" "recipe_ai_generator" {
  function_name = "${var.project_name}-recipe-ai-generator"
  role          = aws_iam_role.lambda_execution_role.arn

  runtime = "nodejs20.x"
  handler = "index.handler"

  filename         = "../../../backend/lambda/dist/recipe_ai_generator.zip"
  source_code_hash = filebase64sha256("../../../backend/lambda/dist/recipe_ai_generator.zip")

  environment {
    variables = {
      GEMINI_API_KEY_ARN          = aws_secretsmanager_secret.gemini_api_key.arn
      GCP_SERVICE_ACCOUNT_KEY_ARN = aws_secretsmanager_secret.gcp_service_account_key.arn
      S3_BUCKET_NAME              = aws_s3_bucket.recipe_images.bucket
      ENVIRONMENT                 = "prod"
      GCP_PROJECT_ID              = var.gcp_project_id
    }
  }

  timeout     = 30
  memory_size = 256

  depends_on = [aws_cloudwatch_log_group.recipe_ai_lambda_log_group]
}

resource "aws_lambda_function" "post_recipe" {
  function_name    = "${var.project_name}-post-recipe"
  role             = aws_iam_role.lambda_execution_role.arn
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  filename         = "../../../backend/lambda/dist/post_recipe.zip"
  source_code_hash = filebase64sha256("../../../backend/lambda/dist/post_recipe.zip")
  environment {
    variables = {
      ENVIRONMENT = "prod"
      TABLE_NAME  = "${aws_dynamodb_table.recipes.name}"
    }
  }

  timeout     = 30
  memory_size = 256
  depends_on  = [aws_cloudwatch_log_group.post_recipe_log_group]
}

resource "aws_lambda_permission" "post_recipe_function" {
  statement_id  = "AllowAPIGatewayInvokePostRecipe"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_recipe.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.recipe_ai_generator.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.main_api.execution_arn}/*/*"
}

# Presigned URL生成Lambda関数
resource "aws_lambda_function" "presigned_url_generator" {
  function_name = "${var.project_name}-presigned-url-generator"
  role          = aws_iam_role.lambda_execution_role.arn

  runtime = "nodejs20.x"
  handler = "index.handler"

  filename         = "../../../backend/lambda/dist/presigned_url.zip"
  source_code_hash = filebase64sha256("../../../backend/lambda/dist/presigned_url.zip")

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.recipe_images.bucket
      ENVIRONMENT    = "prod"
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

resource "aws_lambda_function" "get_recipes" {
  function_name = "${var.project_name}-get-recipes"
  role          = aws_iam_role.lambda_execution_role.arn

  runtime = "nodejs20.x"
  handler = "index.handler"

  filename         = "../../../backend/lambda/dist/get_recipes.zip"
  source_code_hash = filebase64sha256("../../../backend/lambda/dist/get_recipes.zip")

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.main_table.name
      ENVIRONMENT         = "prod"
    }
  }

  timeout     = 10
  memory_size = 128

  depends_on = [aws_cloudwatch_log_group.get_recipes_lambda_log_group]
}

resource "aws_lambda_permission" "api_gateway_get_recipes_lambda" {
  statement_id  = "AllowAPIGatewayInvokeGetRecipes"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_recipes.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.main_api.execution_arn}/*/*"
}

resource "aws_lambda_function" "recipe_ai_generator" {
  function_name = "${var.project_name}-recipe-ai-generator"
  role          = aws_iam_role.lambda_execution_role.arn

  runtime = "nodejs20.x"
  handler = "index.handler"

  filename         = "../../../backend/lambda/dist/recipe_ai_generator.zip"
  source_code_hash = filebase64sha256("../../../backend/lambda/dist/recipe_ai_generator.zip")

  environment {
    variables = {
      GEMINI_API_KEY_ARN = aws_secretsmanager_secret.gemini_api_key.arn
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
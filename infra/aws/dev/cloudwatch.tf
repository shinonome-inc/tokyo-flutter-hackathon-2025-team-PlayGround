resource "aws_cloudwatch_log_group" "recipe_ai_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-recipe-ai-generator"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "presigned_url_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-presigned-url-generator"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "get_recipes_lambda_log_group" {
  name              = "/aws/lambda/${var.project_name}-get-recipes"
  retention_in_days = 14
}
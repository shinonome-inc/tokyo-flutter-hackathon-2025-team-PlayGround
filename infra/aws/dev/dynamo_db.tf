resource "aws_dynamodb_table" "users" {
  name         = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "Id"
  range_key    = "CreatedAt"
  attribute {
    name = "UserId"
    type = "S"
  }
  attribute {
    name = "CreatedAt"
    type = "S"
  }
}

resource "aws_dynamodb_table" "recipes" {
  name         = "recipes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "RecipeId"
  range_key    = "CreatedAt"
  attribute {
    name = "Id"
    type = "S"
  }
  attribute {
    name = "CreatedAt"
    type = "S"
  }
}

resource "aws_dynamodb_table" "ingredients" {
  name         = "ingredients"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = aws_dynamodb_table.recipes.hash_key
  range_key    = "IngredientId"
  attribute {
    name = aws_dynamodb_table.recipes.hash_key
    type = "S"
  }
  attribute {
    name = "IngredientId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "steps" {
  name         = "steps"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = aws_dynamodb_table.recipes.hash_key
  range_key    = "OrderNumber"
  attribute {
    name = aws_dynamodb_table.recipes.hash_key
    type = "S"
  }
  attribute {
    name = "OrderNumber"
    type = "N"
  }
}

resource "aws_dynamodb_table" "comments" {
  name         = "comments"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = aws_dynamodb_table.recipes.hash_key
  range_key    = "CreatedAt"
  attribute {
    name = aws_dynamodb_table.recipes.hash_key
    type = "S"
  }
  attribute {
    name = "CreatedAt"
    type = "S"
  }
}

resource "aws_dynamodb_table" "recipe_reactions" {
  name         = "recipe_reactions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = aws_dynamodb_table.recipes.hash_key
  range_key    = "CreatedAt"
  attribute {
    name = aws_dynamodb_table.recipes.hash_key
    type = "S"
  }
  attribute {
    name = "CreatedAt"
    type = "S"
  }
}
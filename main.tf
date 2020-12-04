provider "aws" {
  region = "eu-west-1"

  # Make it faster by skipping something
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true

  # skip_requesting_account_id should be disabled to generate valid ARN in apigatewayv2_api_execution_arn
  skip_requesting_account_id = false
}

resource "aws_appsync_graphql_api" "todote" {
  authentication_type = "API_KEY"
  name                = "todote"

  schema = file("schema.graphql")
}

resource "aws_appsync_datasource" "todoist" {
  api_id = aws_appsync_graphql_api.todote.id
  name   = "dynamodb1"
  type   = "AMAZON_DYNAMODB"
    
  dynamodb_config {
    table_name = aws_dynamodb_table.todoist.id
  }
}

resource "aws_appsync_resolver" "post" {
  api_id      = "todote"
  field       = "Post"
  type        = "Query"
  data_source = aws_appsync_datasource.todoist.name

  request_template = file("vtl-templates/request.Query.Post.vtl")
  response_template = file("vtl-templates/response.Query.Post.vtl")
}





resource "aws_dynamodb_table" "todoist" {
  name           = "todoist"
  hash_key       = "id"
  billing_mode   = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
  }
}

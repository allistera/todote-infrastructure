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

module "appsync" {
  source = "terraform-aws-modules/appsync/aws"

  name = "todote"

  schema = file("schema.graphql")

  api_keys = {
    default = null # such key will expire in 7 days
  }

  datasources = {
    dynamodb1 = {
      type       = "AMAZON_DYNAMODB"
      table_name = aws_dynamodb_table.todoist.id
      region     = "eu-west-1"
    }
  }

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

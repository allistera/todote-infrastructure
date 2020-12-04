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
      table_name = aws_dynamodb_table.todote.id
      region     = "eu-west-1"
    }
  }

  resolvers = {
    "Query.Task" = {
      data_source       = "dynamodb1"
      request_template  = file("vtl-templates/request.Query.Task.vtl")
      response_template = file("vtl-templates/response.Query.Task.vtl")
    }
    
    "Query.Tasks" = {
      data_source       = "dynamodb1"
      request_template  = file("vtl-templates/request.Query.Tasks.vtl")
      response_template = file("vtl-templates/response.Query.Tasks.vtl")
    }
    
    "Mutation.createTask" = {
      data_source       = "dynamodb1"
      request_template  = file("vtl-templates/request.Mutation.createTask.vtl")
      response_template = file("vtl-templates/response.Mutation.createTask.vtl")
    }
    
    "Mutation.deleteTask" = {
      data_source       = "dynamodb1"
      request_template  = file("vtl-templates/request.Mutation.deleteTask.vtl")
      response_template = file("vtl-templates/response.Mutation.deleteTask.vtl")
    }
    
    "Mutation.updateTask" = {
      data_source       = "dynamodb1"
      request_template  = file("vtl-templates/request.Mutation.updateTask.vtl")
      response_template = file("vtl-templates/response.Mutation.updateTask.vtl")
    }
  }
}


resource "aws_dynamodb_table" "todote" {
  name           = "todote"
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

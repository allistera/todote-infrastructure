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
    "Query.Post" = {
      data_source       = "dynamodb1"
      request_template  = file("vtl-templates/request.Query.Post.vtl")
      response_template = file("vtl-templates/response.Query.Post.vtl")
    }
    
    "Query.Posts" = {
      data_source       = "dynamodb1"
      request_template  = file("vtl-templates/request.Query.Posts.vtl")
      response_template = file("vtl-templates/response.Query.Posts.vtl")
    }
    
    "Mutation.createPost" = {
      data_source       = "dynamodb1"
      request_template  = file("vtl-templates/request.Mutation.createPost.vtl")
      response_template = file("vtl-templates/response.Mutation.createPost.vtl")
    }
    
    "Mutation.deletePost" = {
      data_source       = "dynamodb1"
      request_template  = file("vtl-templates/request.Mutation.deletePost.vtl")
      response_template = file("vtl-templates/response.Mutation.deletePost.vtl")
    }
    
    "Mutation.updatePost" = {
      data_source       = "dynamodb1"
      request_template  = file("vtl-templates/request.Mutation.updatePost.vtl")
      response_template = file("vtl-templates/response.Mutation.updatePost.vtl")
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

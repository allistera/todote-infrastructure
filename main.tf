module "appsync" {
  source = "terraform-aws-modules/appsync/aws"

  name = "dev-appsync"

  schema = file("schema.graphql")

  api_keys = {
    default = null # such key will expire in 7 days
  }

  datasources = {
    registry_terraform_io = {
      type     = "HTTP"
      endpoint = "https://registry.terraform.io"
    }
  }

  resolvers = {
    "Query.getModuleFromRegistry" = {
      data_source       = "registry_terraform_io"
      request_template  = file("vtl-templates/request.Query.getModuleFromRegistry.vtl")
      response_template = file("vtl-templates/response.Query.getModuleFromRegistry.vtl")
    }
  }
}

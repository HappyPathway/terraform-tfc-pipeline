data "aws_iam_policy_document" "s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

locals {
  example_build_variables = [
    {
      name  = "TF_VAR_greeting",
      value = "Dave",
      type  = "PLAINTEXT"
    }
  ]
}

module "main" {
  #source                      = "../"
  source                      = "HappyPathway/pipeline/tfc"
  environment                 = "dev"
  project_name                = "tf-hello-world"
  create_new_repo             = true
  create_new_role             = true
  build_permissions_iam_doc   = data.aws_iam_policy_document.s3_access
  build_environment_variables = local.example_build_variables
  source_repos = [
    {
      name          = "tf-hello-world",
      branch        = "main",
      provider_type = "CodeCommit"
    }
  ]
}

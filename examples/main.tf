data "aws_iam_policy_document" "s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

# locals {
#   example_build_variables = [
#     {
#       name  = "TF_VAR_greeting",
#       value = "Dave",
#       type  = "PLAINTEXT"
#     },
#     {
#       name = "TF_VAR_bucket_name",
#       value = "tf-hello-world",
#       type = "PLAINTEXT"
#     }
#   ]
# }

module "main" {
  source                      = "../"
  project_name                = "tf-hello-dave"
  environment                 = "dev"
  source_repo_name            = "terraform-sample-repo"
  source_repo_branch          = "main"
  create_new_repo             = true
  create_new_role             = true
  build_permissions_iam_doc   = data.aws_iam_policy_document.s3_access
  # build_environment_variables = local.example_build_variables
  # enable_destroy = true
  workspace_vars = {
    greeting = "Dave",
    bucket_name = "tf-hello-world"
  }
  state = {
    bucket         = "inf-tfstate-229685449397"
    key_prefix     = "csvd-dev-gov/common/apps"
    region         = "us-gov-east-1"
    dynamodb_table = "tf_remote_state"
  }
}

data "aws_iam_policy_document" "s3_access" {
  statement {
    effect = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

locals {
  example_build_variables = [
    {
      name = "TF_VAR_greeting",
      value = "Dave",
      type = "PLAINTEXT"
    }
  ]
}

module main {
  source = "../"
  project_name       = "tf-hello-world"
  environment        = "dev"
  source_repo_name   = "terraform-sample-repo"
  source_repo_branch = "main"
  create_new_repo    = true
  create_new_role    = true
  build_permissions_iam_doc = data.aws_iam_policy_document.s3_access
  build_environment_variables = local.example_build_variables
  enable_destroy = true
  state = {
    profile        = "229685449397-csvd-dev-gov"
    bucket         = "inf-tfstate-229685449397"
    key            = "csvd-dev-gov/common/apps/tfc-pipeline/terraform.tfstate"
    region         = "us-gov-east-1"
    dynamodb_table = "tf_remote_state"
  }
}

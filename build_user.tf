resource "aws_iam_user" "build_user" {
  name = var.project_name
  path = "/tf-pipeline/${var.environment}/${var.project_name}"
  tags = {
    Project_Name = var.project_name
    Environment  = var.environment
    Account_ID   = local.account_id
    Region       = local.region
  }
}

data "aws_iam_policy_document" "state_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${lookup(local.state, "bucket")}/${lookup(local.state, "key")}/${var.environment}"]
  }

  statement  {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:s3:::${lookup(local.state, "bucket")}"]
  }

  statement {
    effect = "Allow"
    actions = [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:dynamodb:${lookup(local.state, "region")}:${data.aws_caller_identity.current.account_id}:table/${lookup(local.state, "dynamodb_table")}"]
  }
}

data "aws_iam_policy_document" "pipeline_access" {
  statement {
    effect = "Allow"
    actions = [
      "codepipeline:GetPipelineState"
    ]
    resources = ["arn:${data.aws_partition.current.partition}:codepipeline:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${var.project_name}"]
  }
}

resource "aws_iam_access_key" "build_user" {
  user = aws_iam_user.build_user.name
}

resource "aws_iam_user_policy" "build_user" {
  for_each = tomap({
    "${var.project_name}-build-user" = var.build_permissions_iam_doc.json,
    "${var.project_name}-state" = data.aws_iam_policy_document.state_access.json,
     "${var.project_name}-pipeline-access" = data.aws_iam_policy_document.pipeline_access.json
  })
  name   = each.key
  user   = aws_iam_user.build_user.name
  policy = each.value
}

resource "random_uuid" "credentials_suffix" {}

resource "aws_secretsmanager_secret" "credentials" {
  name = "${var.project_name}-${var.environment}-aws-credentials-${random_uuid.credentials_suffix.result}"
}

resource "aws_secretsmanager_secret_version" "credentials" {
  secret_id     = aws_secretsmanager_secret.credentials.id
  secret_string = aws_iam_access_key.build_user.secret
}
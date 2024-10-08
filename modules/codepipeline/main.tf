#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

resource "aws_codepipeline" "terraform_pipeline" {

  name     = var.project_name
  role_arn = var.codepipeline_role_arn
  tags     = var.tags

  artifact_store {
    location = var.s3_bucket_name
    type     = "S3"
    encryption_key {
      id   = var.kms_key_arn
      type = "KMS"
    }
  }

  dynamic "stage" {
    for_each = var.code_source == "codestar" ? ["*"] : []
    content {
      name = "Source"
      action {
        name             = "Source"
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeStarSourceConnection"
        version          = "1"
        output_artifacts = ["SourceOutput"]

        configuration = {
          ConnectionArn    = var.aws_codestarconnections_connection_arn
          FullRepositoryId = "${var.source_repo_org}/${var.source_repo_name}"
          BranchName       = var.source_repo_branch
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.code_source == "codecommit" ? ["*"] : []
    content {
      name = "Source"

      action {
        name             = "Download-Source"
        category         = "Source"
        owner            = "AWS"
        version          = "1"
        provider         = "CodeCommit"
        namespace        = "SourceVariables"
        output_artifacts = ["SourceOutput"]
        run_order        = 1

        configuration = {
          RepositoryName       = var.source_repo_name
          BranchName           = var.source_repo_branch
          PollForSourceChanges = "true"
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.stages

    content {
      name = title(stage.value["name"])
      action {
        category         = stage.value["category"]
        name             = stage.value["name"]
        owner            = stage.value["owner"]
        provider         = stage.value["provider"]
        input_artifacts  = lookup(stage.value, "input_artifacts", "") != "" ? [stage.value["input_artifacts"]] : null
        output_artifacts = lookup(stage.value, "output_artifacts", "") != "" ? [stage.value["output_artifacts"]] : null
        version          = "1"
        run_order        = index(var.stages, stage.value) + 2

        configuration = {
          ProjectName = stage.value["provider"] == "CodeBuild" ? "${var.project_name}-${stage.value["name"]}" : null
        }
      }
    }
  }

}
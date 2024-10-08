#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

locals {
  # type - (Optional) Type of environment variable. Valid values: PARAMETER_STORE, PLAINTEXT, SECRETS_MANAGER.
  workspace_secrets = [
    for secret, value in nonsensitive(var.workspace_secrets) : 
      { 
        value = value, 
        name = startswith(secret, "TF_VAR_") ? secret : "TF_VAR_${secret}", 
        type = "SECRETS_MANAGER"
      }
  ]
  workspace_parameters = [
    for parameter, value in var.workspace_parameters : 
      {
        value = value, 
        name = startswith(parameter, "TF_VAR_") ? parameter : "TF_VAR_${parameter}"
        type = "PARAMETER_STORE"
      }
  ]
  workspace_vars = [
    for _var, value in var.workspace_vars : 
      {
        value = value,
        name = startswith(_var, "TF_VAR_") ? _var : "TF_VAR_${_var}",
        type = "PLAINTEXT"
      }
  ]
  environment_variables = tolist(concat(
    var.environment_variables,
    local.workspace_secrets,
    local.workspace_parameters,
    local.workspace_vars
  ))
}

resource "aws_codebuild_project" "terraform_codebuild_project" {

  for_each = toset(var.build_projects)

  name           = "${var.project_name}-${each.value}"
  service_role   = var.role_arn
  encryption_key = var.kms_key_arn
  tags           = var.tags
  artifacts {
    type = var.build_project_source
  }
  environment {
    compute_type                = var.builder_compute_type
    image                       = var.builder_image
    type                        = var.builder_type
    privileged_mode             = true
    image_pull_credentials_type = var.builder_image_pull_credentials_type
    dynamic "environment_variable" {
      for_each = tolist([ for _var in local.environment_variables : tomap(_var) ])
      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
        type  = environment_variable.value.type
      }
    }
  }
  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }
  source {
    type = var.build_project_source
    buildspec = templatefile(
      "${path.module}/templates/buildspec_${each.value}.yml",
      {
        terraform_version = var.terraform_version,
        state             = var.state,
        environment       = lookup(var.tags, "Environment"),
        pipeline_name     = var.project_name
      }
    )
  }
  lifecycle {
    ignore_changes = [
      project_visibility
    ]
  }
}

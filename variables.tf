#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "create_new_repo" {
  description = "Whether to create a new repository. Values are true or false. Defaulted to true always."
  type        = bool
  default     = true
}

variable "create_new_role" {
  description = "Whether to create a new IAM Role. Values are true or false. Defaulted to true always."
  type        = bool
  default     = true
}

variable "codepipeline_iam_role_name" {
  description = "Name of the IAM role to be used by the Codepipeline"
  type        = string
  default     = "codepipeline-role"
}

variable "source_repo_name" {
  description = "Source repo name of the CodeCommit repository"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
}

# variable "repo_approvers_arn" {
#   description = "ARN or ARN pattern for the IAM User/Role/Group that can be used for approving Pull Requests"
#   type        = string
# }

variable "environment" {
  description = "Environment in which the script is run. Eg: dev, prod, etc"
  type        = string
}

variable "stage_input" {
  description = "Tags to be attached to the CodePipeline"
  type        = list(map(any))
  default = [
    { name = "init", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "InitOutput" },
    { name = "validate", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "InitOutput", output_artifacts = "ValidateOutput" },
    { name = "plan", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "ValidateOutput", output_artifacts = "PlanOutput" },
    { name = "approve", category = "Approval", owner = "AWS", provider = "Manual" },
    { name = "apply", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts = "PlanOutput", output_artifacts = "ApplyOutput" },
  ]
}

variable "destroy_stage_input"{
  description = "Stages for a terraform destroy"
  default = [
    { name = "init", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "SourceOutput", output_artifacts = "InitOutput" },
    { name = "plan_destroy", category = "Test", owner = "AWS", provider = "CodeBuild", input_artifacts = "InitOutput", output_artifacts = "PlanDestroyOutput" },
    { name = "approve", category = "Approval", owner = "AWS", provider = "Manual" },
    { name = "destroy", category = "Build", owner = "AWS", provider = "CodeBuild", input_artifacts  = "PlanDestroyOutput", output_artifacts = "DestroyOutput"}
  ]
}

variable "build_projects" {
  description = "Tags to be attached to the CodePipeline"
  type        = list(string)
  default     = ["init", "validate", "plan", "apply"]
}


variable "destroy_projects" {
  description = "Tags to be attached to the CodePipeline"
  type        = list(string)
  default     = ["init", "plan_destroy","destroy"]
}

variable "builder_compute_type" {
  description = "Relative path to the Apply and Destroy build spec file"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "builder_image" {
  description = "Docker Image to be used by codebuild"
  type        = string
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "builder_type" {
  description = "Type of codebuild run environment"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "builder_image_pull_credentials_type" {
  description = "Image pull credentials type used by codebuild project"
  type        = string
  default     = "CODEBUILD"
}

variable "build_project_source" {
  description = "aws/codebuild/standard:4.0"
  type        = string
  default     = "CODEPIPELINE"
}


variable "build_environment_variables" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  default = []
}

variable "terraform_version" {
  type        = string
  description = "Terraform CLI Version"
  default     = "1.7.5"
}

variable "build_permissions_iam_doc" {
  type = any
}

variable "enable_destroy" {
  type        = bool
  description = "Enable Destroy"
  default     = false
}

variable "state" {
  type = object(
    {
      bucket         = string
      key_prefix     = string
      region         = string
      dynamodb_table = string
    }
  )
}

variable workspace_parameters {
  type = map(string)
  default = {}
}

variable workspace_secrets {
  sensitive = true
  type = map(string)
  default = {}
}

variable workspace_vars {
  type = map(string)
  default = {}
}

variable "aws_codestarconnections_connection_arn" {
  default = null
  type = string
  description = "If using a codestar connection, specify the arn of that codestart connection here"
}

variable "source_repo_org" {
  default = null
  type = string
  description = "If using a codestar connection, specify the github organization of the repo"
}


variable code_source {
  default = "codecommit"
  type = string
  description = "specify if pulling from codecommit or codestar"
  validation {
    condition     = contains(["codecommit", "codestar"], var.code_source)
    error_message = "Currently this pipeline module only supports code commit and code star connections. Please specify either codecommit or codestar"
  }
}
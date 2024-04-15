#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

variable "project_name" {
  description = "Unique name for this project"
  type        = string
}

variable "source_repo_name" {
  description = "Source repo name of the CodeCommit repository"
  type        = string
}

variable "source_repo_branch" {
  description = "Default branch in the Source repo for which CodePipeline needs to be configured"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket name to be used for storing the artifacts"
  type        = string
}

variable "codepipeline_role_arn" {
  description = "ARN of the codepipeline IAM role"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "tags" {
  description = "Tags to be attached to the CodePipeline"
  type        = map(any)
}

variable "stages" {
  description = "List of Map containing information about the stages of the CodePipeline"
  type        = list(map(any))
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
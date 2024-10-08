#This solution, non-production-ready template describes AWS Codepipeline based CICD Pipeline for terraform code deployment.
#© 2023 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.
#This AWS Content is provided subject to the terms of the AWS Customer Agreement available at
#http://aws.amazon.com/agreement or other written agreement between Customer and either
#Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

output "id" {
  value       = [ for project in aws_codebuild_project.terraform_codebuild_project : project.id ]
  description = "List of IDs of the CodeBuild projects"
}

output "name" {
  value       = [ for project in aws_codebuild_project.terraform_codebuild_project : project.name ]
  description = "List of Names of the CodeBuild projects"
}

output "arn" {
  value       = [ for project in aws_codebuild_project.terraform_codebuild_project : project.arn ]
  description = "List of ARNs of the CodeBuild projects"
}


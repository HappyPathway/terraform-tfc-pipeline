data "aws_caller_identity" "current" {}

variable bucket_name {
  default = "tf-pipeline-test"
}

variable greeting {
  default = "world"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket_prefix = regex("[a-z0-9.-]+", lower(var.bucket_name == "tf-pipeline-test" ? "${var.bucket_name}-${split("-", uuid())[0]}" : var.bucket_name))
  force_destroy = true
}

output "hello" {
  value = "hello ${var.greeting}!"
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

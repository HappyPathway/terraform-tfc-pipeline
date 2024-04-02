module main {
  source = "../"
  project_name       = "tf-hello-world"
  environment        = "dev"
  source_repo_name   = "terraform-sample-repo"
  source_repo_branch = "main"
  create_new_repo    = true
  create_new_role    = true
  build_environment_variables = [
    {
      name = "TF_VAR_greeting",
      value = "Dave",
      type = "PLAINTEXT"
    }
  ]
}

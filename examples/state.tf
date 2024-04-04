# module "tfstate" {
#    source = "git@github.e.it.census.gov:terraform-modules/aws-inf-setup.git//terraform-state"
#    account_alias         = "csvd-dev-ew"

#    # optional, defaults
#    tfstate_key_prefix    = "tfc-pipeline"
#    kms_tfstate_key       = "tfc-pipeline"
#    tfstate_table         = "tfc-pipeline"
#    tfstate_bucket        = "tfc-pipeline"
#    tfstate_bucket_prefix = "tfc-pipeline"
#    tfstate_key_suffix    = "terraform.tfstate"
#    sso_permissionset_names =  [ "inf-terraform" ]
# }
# module "tfstate" {
#    source = "git@github.e.it.census.gov:terraform-modules/aws-inf-setup.git//terraform-state"
#    account_alias         = "csvd-dev-ew"
# }
# output tfstate {
#     value = module.tfstate
# }
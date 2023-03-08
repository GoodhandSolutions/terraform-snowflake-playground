terraform {
  required_version = ">= 1.1.7"

  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.54.0"
    }
  }

  backend "s3" {
    bucket = "goodhand-solutions-terraform-state"
    key    = "terraform-snowflake-playground/terraform.tfstate"
    region = "eu-west-1"
  }

}

provider "snowflake" {
  username  = var.snowflake_user
  account   = var.snowflake_account
  region    = var.snowflake_region
  warehouse = var.deployment_warehouse

  private_key_path = var.snowflake_rsa_key_path

  role = "SYSADMIN"
}

module "playground" {
  source = "../.." #"jagoodhand/playground/snowflake"

  tasks_enabled = true
  dry_run       = true

  max_object_age_without_tag = 31
  max_expiry_days            = 90

  playground = {
    database              = "TEST_PLAYGROUND"
    schema                = "GROUND"
    is_transient          = false
    administration_schema = "ADMINISTRATION"
  }

  playground_warehouse = {
    name = "playground_test_warehouse"
    size = "xsmall"
  }

  expiry_date_tag = {
    database = "TEST_PLAYGROUND"
    schema   = "ADMINISTRATION"
    name     = "EXPIRY_DATE"
    create   = true
  }
}

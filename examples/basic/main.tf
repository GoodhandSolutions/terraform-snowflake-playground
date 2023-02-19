terraform {
  required_version = ">= 1.1.7"

  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.54.0"
    }
  }
}

provider "snowflake" {
  username  = var.snowflake_user
  account   = var.snowflake_account
  region    = var.snowflake_region
  warehouse = var.deployment_warehouse

  private_key_path = var.snowflake_rsa_key_path

  role = "ACCOUNTADMIN"
}

module "playground" {
  source = "../.." #"jagoodhand/playground/snowflake"

  max_object_age_without_tag = 2

  tasks_enabled = true
  dry_run       = false

  playground = {
    database              = "PLAY"
    schema                = "GROUND"
    is_transient          = false
    administration_schema = "ADMINISTRATION"
  }
}

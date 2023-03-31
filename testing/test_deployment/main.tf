terraform {
  required_version = ">= 1.1.7"

  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = ">= 0.60.0"
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

resource "snowflake_table" "static_object_ages" {
  depends_on = [
    module.playground
  ]
  database = "TEST_PLAYGROUND"
  schema   = "ADMINISTRATION"
  name     = "STATIC_OBJECT_AGES"

  column {
    name = "OBJECT_DATABASE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "OBJECT_SCHEMA"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "OBJECT_NAME"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "OBJECT_TYPE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "OBJECT_DOMAIN"
    type = "VARCHAR(9)"
  }

  column {
    name = "TAG_DOMAIN"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "SQL_OBJECT_TYPE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "DAYS_SINCE_CREATION"
    type = "NUMBER(9,0)"
  }

  column {
    name = "DAYS_SINCE_LAST_ALTERATION"
    type = "NUMBER(9,0)"
  }

  column {
    name = "EXPIRY_DATE"
    type = "DATE"
  }

  column {
    name = "OBJECT_OWNER"
    type = "VARCHAR(16777216)"
  }
}

resource "snowflake_table_grant" "static_object_ages_grant" {
  database_name = "TEST_PLAYGROUND"
  schema_name   = "ADMINISTRATION"
  table_name    = snowflake_table.static_object_ages.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

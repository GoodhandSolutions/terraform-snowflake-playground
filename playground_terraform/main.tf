# TODO: Convert this into a module. Have some example deployment code in here, but primarily this repo should just be a module.
terraform {
    required_version = ">= 1.1.7"

    required_providers {
        snowflake = {
        source = "Snowflake-Labs/snowflake"
        version = "0.54.0"
        }
    }
}

provider "snowflake" {
    username = var.snowflake_user
    account = var.snowflake_account
    region = var.snowflake_region

    private_key_path = var.snowflake_rsa_key_path

    role = "ACCOUNTADMIN"
}
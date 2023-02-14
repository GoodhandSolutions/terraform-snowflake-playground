###############################################################
# Snowflake Access Variables
###############################################################

# Populated via environment variable, rather than storing in Git.
variable "snowflake_user" {
  type = string
}

# Populated via environment variable, rather than storing in Git.
variable "snowflake_account" {
  type = string
}

# Populated via environment variable, rather than storing in Git.
variable "snowflake_rsa_key_path" {
  type = string
}

variable "snowflake_region" {
  type = string
  default = "eu-west-1"
}

variable "deployment_warehouse" {
  type = string
  default = "COMPUTE_WH"
}

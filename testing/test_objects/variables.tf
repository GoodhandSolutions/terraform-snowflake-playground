###############################################################
# Snowflake Access Variables
###############################################################

# Populated via environment variable, rather than storing in Git.
variable "snowflake_user" {
  type        = string
  description = "Snowflake username to connect to Snowflake with."
}

# Populated via environment variable, rather than storing in Git.
variable "snowflake_account" {
  type        = string
  description = "Snowflake account ID of the account to connect to."
}

# Populated via environment variable, rather than storing in Git.
variable "snowflake_rsa_key_path" {
  type        = string
  description = "Path of the RSA key to use to authenticate to Snowflake with."
}

variable "snowflake_region" {
  type        = string
  default     = "eu-west-1"
  description = "Snowflake region of the Snowflake account you want to connect to."
}

variable "deployment_warehouse" {
  type        = string
  default     = "COMPUTE_WH"
  description = "Name of the Snowflake warehouse that should be used to deploy the terraform."
}

variable "test_db" {
  type        = string
  default     = "TEST_PLAYGROUND"
  description = "Name of the Snowflake database to use for testing."
}

variable "test_schema" {
  type        = string
  default     = "GROUND"
  description = "Name of the Snowflake schema to use for testing."
}

variable "test_warehouse" {
  type        = string
  default     = "COMPUTE_WH"
  description = "Warehouse to use for testing."
}

variable "test_tag" {
  type        = string
  default     = "TEST_PLAYGROUND.ADMINISTRATION.EXPIRY_DATE"
  description = "Expiry date tag to use for testing."
}

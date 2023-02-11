###############################################################
# Snowflake Access Variables
###############################################################

variable "snowflake_user" {
  type = string
}

variable "snowflake_account" {
  type = string
}

variable "snowflake_region" {
  type = string
  default = "eu-west-1"
}

variable "snowflake_rsa_key_path" {
  type = string
}

variable "deployment_warehouse" {
  type = string
  default = "COMPUTE_WH"
}

###############################################################
# Playground Configuration Variables
###############################################################

variable "data_retention_time" {
    type = number
}

variable "playground_db_name" {
    type = string
    default = "PLAY"
}

variable "playground_schema_name" {
    type = string
    default = "GROUND"
}

variable "playground_admin_schema_name" {
    type = string
    default = "ADMINISTRATION"
}

variable "playground_object_allowed_duration_days" {
    type = number
    default = 90
}

variable "playground_warehouse_name" {
    type = string
    default = "playground_admin_warehouse"
}

variable "playground_warehouse_size" {
    type = string
    default = "xsmall"
}

variable "expiry_date_tag_database" {
    type = string
    default = "PLAY"
}

variable "expiry_date_tag_schema" {
    type = string
    default = "ADMINISTRATION"
}

variable "expiry_date_tag_name" {
    type = string
    default = "EXPIRY_DATE"
}

variable "max_object_age_without_tag" {
    type = number
    default = 31
}

variable "max_expiry_days" {
    type = number
    default = 90
}

variable "tasks_enabled" {
    type = bool
    default = true
}

variable "dry_run" {
    type = bool
    default = false
}
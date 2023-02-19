###############################################################
# Playground Configuration Variables
###############################################################

variable "playground" {
  type = object({
    database              = string
    schema                = string
    administration_schema = string
  })

  description = "Database, schema and administration schema names to use for the Playground."

  default = {
    database              = "PLAY"
    schema                = "GROUND"
    administration_schema = "ADMINISTRATION"
  }
}

variable "playground_warehouse" {
  type = object({
    name = string
    size = string
  })

  description = "Warehouse to use for executing the playground automation functions."

  default = {
    name = "playground_admin_warehouse"
    size = "xsmall"
  }
}

variable "expiry_date_tag" {
  type = object({
    database = string
    schema   = string
    name     = string
    create   = bool
  })

  description = "Details regarding the location and name of the EXPIRY_DATE tag. If `create = true` then a new tag will be created, otherwise will assume a current tag exists with this name. If using an existing tag, you MUST grant 'APPLY' on this tag to the 'PUBLIC' role. This will not be done by the terraform module."

  default = {
    database = "PLAY"
    schema   = "ADMINISTRATION"
    name     = "EXPIRY_DATE"
    create   = true
  }
}

variable "data_retention_time" {
  type        = number
  default     = 1
  description = "Snowflake Data Retention value for the Playground Schema."
}

variable "max_object_age_without_tag" {
  type        = number
  default     = 31
  description = "Max number of days to allow an object to exist in the playground without an expiry date before it is dropped."
}

variable "max_expiry_days" {
  type        = number
  default     = 90
  description = "Max number of days that an expiry date tag can be set in the future. If a tag is set beyond this value, then it will be reduced to the date defined by this number of days in the future."
}

variable "tasks_enabled" {
  type        = bool
  default     = false
  description = "Whether the playground tidying tasks are enabled or not."
}

variable "dry_run" {
  type        = bool
  default     = true
  description = "Whether the playground tidying procedure should alter tags / drop objects, or just log its planned actions."
}

variable "task_cron_schedule" {
  type        = string
  default     = "USING CRON 0 3 * * * UTC"
  description = "CRON schedule on which the playground tidying tasks should be executed."
}

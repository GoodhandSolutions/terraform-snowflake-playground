###############################################################
# Playground Configuration Variables
###############################################################

variable "data_retention_time" {
    type = number
    default = 1
    description = "Snowflake Data Retention value for the Playground Schema."
}

variable "playground_db_name" {
    type = string
    default = "PLAY"
    description = "Name of the database that should be created to house the Playground environment. Must not be an existing database name."
}

variable "playground_schema_name" {
    type = string
    default = "GROUND"
    description = "Name of the schema within the Playground Database where the Playground environment will exist."
}

variable "playground_admin_schema_name" {
    type = string
    default = "ADMINISTRATION"
    description = "Name of the administrative schema within the Playground Database where the supporting objects for the playground will be created."
}

variable "playground_warehouse_name" {
    type = string
    default = "playground_admin_warehouse"
    description = "Name of the warehouse that will be used to perform Playground activities. A new warehouse will be created to manage the playground activities."
}

variable "playground_warehouse_size" {
    type = string
    default = "xsmall"
    description = "Size of the warehouse that will be used to support the Playground activities. XS should be apprioriate unless you have a particularly large account. In this case, you can look at the query times of the warehouse, and experiment with increasing the warehouse size."
}

variable "expiry_date_tag_database" {
    type = string
    default = "PLAY"
    description = "Database where the expiry date tag utilised for the playground should be created."
}

variable "expiry_date_tag_schema" {
    type = string
    default = "ADMINISTRATION"
    description = "Schema where the expiry date tag utilitsed for the playground should be created."
}

variable "expiry_date_tag_name" {
    type = string
    default = "EXPIRY_DATE"
    description = "Name for the expiry date tag."
}

variable "max_object_age_without_tag" {
    type = number
    default = 31
    description = "Max number of days to allow an object to exist in the playground without an expiry date before it is dropped."
}

variable "max_expiry_days" {
    type = number
    default = 90
    description = "Max number of days that an expiry date tag can be set in the future. If a tag is set beyond this value, then it will be reduced to the date defined by this number of days in the future."
}

variable "tasks_enabled" {
    type = bool
    default = false
    description = "Whether the playground tidying tasks are enabled or not."
}

variable "dry_run" {
    type = bool
    default = true
    description = "Whether the playground tidying procedure should alter tags / drop objects, or just log its planned actions."
}

variable "task_cron_schedule" {
    type = string
    default = "USING CRON 0 3 * * * UTC"
    description = "CRON schedule on which the playground tidying tasks should be executed."
}
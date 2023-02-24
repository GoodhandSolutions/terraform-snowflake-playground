###############################################################
# Schema Definition
###############################################################
resource "snowflake_schema" "administration" {
  depends_on = [
    snowflake_database.play
  ]

  database = snowflake_database.play.name
  name     = var.playground.administration_schema

  is_transient = false
  is_managed   = true
}

resource "snowflake_schema_grant" "play_administration_grant_usage" {
  depends_on = [
    snowflake_schema.administration
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.administration.name

  privilege = "USAGE"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

###############################################################
# Expiration tag definitions and views
###############################################################
resource "snowflake_tag" "expiry_date_tag" {
  depends_on = [
    snowflake_schema.administration
  ]
  count = var.expiry_date_tag.create ? 1 : 0

  database = var.expiry_date_tag.database
  schema   = var.expiry_date_tag.schema
  name     = var.expiry_date_tag.name

  comment = "Tag values must be in the form of YYYY-MM-DD."
}

resource "snowflake_tag_grant" "expiry_date_apply_grant" {
  depends_on = [
    snowflake_tag.expiry_date_tag
  ]
  count = var.expiry_date_tag.create ? 1 : 0

  database_name = var.expiry_date_tag.database
  schema_name   = var.expiry_date_tag.schema
  tag_name      = var.expiry_date_tag.name

  roles     = ["PUBLIC"]
  privilege = "APPLY"
}

resource "snowflake_view" "object_tags" {
  depends_on = [
    snowflake_schema.administration
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "OBJECT_TAGS"

  statement = templatefile("${path.module}/code/sql/views/object_tags.sql", {
    "expiry_date_tag_database" = var.expiry_date_tag.database
    "expiry_date_tag_schema"   = var.expiry_date_tag.schema
  })
}

resource "snowflake_view_grant" "select_object_tags_grant" {
  depends_on = [
    snowflake_view.object_tags
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.administration.name
  view_name     = snowflake_view.object_tags.name

  privilege = "SELECT"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

###############################################################
# Handle objects only available via 'SHOW'
###############################################################
resource "snowflake_table" "tasks" {
  depends_on = [
    snowflake_schema.administration
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "TASKS"

  change_tracking = true

  column {
    name = "CREATED_ON"
    type = "TIMESTAMP_LTZ(3)"
  }

  column {
    name = "NAME"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "ID"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "DATABASE_NAME"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "SCHEMA_NAME"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "OWNER"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "COMMENT"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "WAREHOUSE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "SCHEDULE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "PREDECESSORS"
    type = "ARRAY"
  }

  column {
    name = "STATE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "DEFINITION"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "CONDITION"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "ALLOW_OVERLAPPING_EXECUTION"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "ERROR_INTEGRATION"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "LAST_COMMITTED_ON"
    type = "TIMESTAMP_LTZ(3)"
  }

  column {
    name = "LAST_SUSPENDED_ON"
    type = "TIMESTAMP_LTZ(3)"
  }
}

resource "snowflake_table" "streams" {
  depends_on = [
    snowflake_schema.administration
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "STREAMS"

  change_tracking = true
  column {
    name = "CREATED_ON"
    type = "TIMESTAMP_LTZ(3)"
  }

  column {
    name = "NAME"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "DATABASE_NAME"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "SCHEMA_NAME"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "OWNER"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "COMMENT"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "TABLE_NAME"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "SOURCE_NAME"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "BASE_TABLES"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "TYPE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "STALE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "MODE"
    type = "VARCHAR(16777216)"
  }

  column {
    name = "STALE_AFTER"
    type = "TIMESTAMP_LTZ(3)"
  }

  column {
    name = "INVALID_REASON"
    type = "VARCHAR(16777216)"
  }
}

resource "snowflake_procedure" "update_objects" {
  /*
  Procedure to get the latest list of STREAM / TASK objects in Snowflake via the 'SHOW' command.
  These object types are not available in the INFORMATION_SCHEMA, and so wouldn't be up-to-date
  otherwise, as would have to come from the delayed 'ACCOUNT_USAGE' schema.
  }
  */

  depends_on = [
    snowflake_table.tasks,
    snowflake_table.streams,
    snowflake_schema.ground
  ]
  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "UPDATE_OBJECTS"

  language = "SQL"
  arguments {
    name = "OBJECT_TYPE"
    type = "VARCHAR"
  }

  return_type = "VARCHAR(16777216)"
  execute_as  = "OWNER"
  statement = templatefile("${path.module}/code/sql/procedures/update_objects.sql", {
    "playground_db"                    = snowflake_database.play.name
    "playground_schema"                = snowflake_schema.ground.name
    "playground_administration_schema" = snowflake_schema.administration.name
  })
}

###############################################################
# Normalize Procedure Names
###############################################################

resource "snowflake_function" "normalize_proc_names" {
  depends_on = [
    snowflake_schema.administration
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "NORMALIZE_PROC_NAMES"

  arguments {
    name = "name"
    type = "VARCHAR"
  }

  arguments {
    name = "source"
    type = "VARCHAR"
  }

  arguments {
    name = "arguments"
    type = "VARCHAR"
  }

  return_type = "VARCHAR"

  language        = "python"
  runtime_version = "3.8"
  handler         = "normalize_procedure_name"
  statement       = file("${path.module}/code/python/normalize_proc_names/normalize_proc_names/normalize_proc_names.py")
}

###############################################################
# View for determining object age
###############################################################
resource "snowflake_view" "object_ages" {
  depends_on = [
    snowflake_schema.administration,
    snowflake_schema.ground,
    snowflake_view.object_tags,
    snowflake_function.normalize_proc_names
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "OBJECT_AGES"

  /*
  This doesn't include the following objects, because they cannot be tagged:
  tags, file formats, functions, masking policies, row access policies, sequences

  You can't have views, materialized views, tables or ext tables with the same name.
  These objects can therefore all be treated as tables.
  */

  statement = templatefile("${path.module}/code/sql/views/object_ages.sql", {
    "playground_db_name"                    = snowflake_database.play.name
    "object_tags_view_path"                 = "${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_tags.name}"
    "playground_schema_name"                = snowflake_schema.ground.name
    "playground_administration_schema_name" = snowflake_schema.administration.name
  })
}

resource "snowflake_view_grant" "select_object_ages_grant" {
  depends_on = [
    snowflake_view.object_ages
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.administration.name
  view_name     = snowflake_view.object_ages.name

  privilege = "SELECT"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

###############################################################
# Log table
###############################################################
resource "snowflake_table" "log_table" {
  depends_on = [
    snowflake_view.object_tags
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "LOG"

  change_tracking = true

  column {
    name     = "EVENT_TIME"
    type     = "TIMESTAMP_TZ(9)"
    nullable = false
  }

  column {
    name = "RECORD"
    type = "VARIANT"
  }

  column {
    name = "RUN_ID"
    type = "VARCHAR(16777216)"
  }
}

resource "snowflake_object_parameter" "log_table_data_retention" {
  depends_on = [
    snowflake_table.log_table
  ]

  object_identifier {
    database = snowflake_database.play.name
    schema   = snowflake_schema.administration.name
    name     = snowflake_table.log_table.name
  }

  key         = "DATA_RETENTION_TIME_IN_DAYS"
  value       = "31"
  object_type = "TABLE"
}

resource "snowflake_view" "log_view" {
  depends_on = [
    snowflake_schema.administration
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "LOG_VIEW"

  statement = templatefile("${path.module}/code/sql/views/log_view.sql", {
    "tbl_path" = "${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_table.log_table.name}"
  })
}

resource "snowflake_view" "log_summary" {
  depends_on = [
    snowflake_schema.administration
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "LOG_SUMMARY"

  statement = templatefile("${path.module}/code/sql/views/log_summary.sql", {
    "tbl_path" = "${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.log_view.name}"
  })
}

###############################################################
# Clean-up Procedure
###############################################################

resource "snowflake_procedure" "tidy_playground" {
  depends_on = [
    snowflake_table.log_table,
    snowflake_view.object_ages,
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "TIDY_PLAYGROUND"

  language    = "PYTHON"
  return_type = "VARCHAR(16777216)"

  runtime_version = "3.8"
  packages        = ["snowflake-snowpark-python"]
  handler         = "main"

  arguments {
    name = "DRY_RUN"
    type = "BOOLEAN"
  }
  execute_as = "OWNER"

  statement = templatefile("${path.module}/code/python/tidy_playground/tidy_playground/tidy_playground.py", {
    "object_ages_view_path"      = "${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_ages.name}"
    "log_table_path"             = "${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_table.log_table.name}"
    "max_expiry_days"            = var.max_expiry_days
    "max_object_age_without_tag" = var.max_object_age_without_tag
    "expiry_date_tag"            = "${var.expiry_date_tag.database}.${var.expiry_date_tag.schema}.${var.expiry_date_tag.name}"
  })
}

/*
resource "snowflake_procedure" "tidy_playground" {
  depends_on = [
    snowflake_table.log_table,
    snowflake_view.object_ages,
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "TIDY_PLAYGROUND"

  language    = "SQL"
  return_type = "VARCHAR(16777216)"
  arguments {
    name = "DRY_RUN"
    type = "BOOLEAN"
  }
  execute_as = "OWNER"

  Includes:
  ext tables, materialized views, pipes, procedures, stages, streams, tables, tasks, views

  Excludes (because they cannot be tagged):
  tags, file formats, functions, masking policies, row access policies, sequences
  Excludes (because they don't exist outside of a session):
  temp tables

  You can't have views, materialized views, tables or ext tables with the same name.
  These objects can therefore all be treated as tables.

  statement = templatefile("${path.module}/code/sql/procedures/tidy_playground.sql", {
    "playground_db"                    = snowflake_database.play.name
    "playground_schema"                = snowflake_schema.ground.name
    "playground_administration_schema" = snowflake_schema.administration.name
    "object_ages_view_path"            = "${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_ages.name}"
    "log_summary_view_path"            = "${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.log_summary.name}"
    "log_table_path"                   = "${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_table.log_table.name}"
    "max_expiry_days"                  = var.max_expiry_days
    "max_object_age_without_tag"       = var.max_object_age_without_tag
    "expiry_date_tag_path"             = "${var.expiry_date_tag.database}.${var.expiry_date_tag.schema}.${var.expiry_date_tag.name}"
  })
}
*/

###############################################################
# Task to execute clean-up
###############################################################
resource "snowflake_warehouse" "playground_admin_warehouse" {
  name           = var.playground_warehouse.name
  warehouse_size = var.playground_warehouse.size

  auto_resume         = true
  auto_suspend        = 59
  initially_suspended = true

  max_cluster_count = 1
  min_cluster_count = 1

  warehouse_type = "STANDARD"
}

resource "snowflake_task" "update_task_objects" {
  depends_on = [
    snowflake_procedure.update_objects,
    snowflake_warehouse.playground_admin_warehouse
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "UPDATE_PLAY_GROUND_TASK_OBJECTS_TASK"

  warehouse = snowflake_warehouse.playground_admin_warehouse.name
  # Given the playground relies on SNOWFLAKE.ACCOUNT_USAGE which can be delayed by up to 3 hours,
  # running at 0300 means that even with delays to reading tags, the behaviour should be as expected.
  schedule      = var.task_cron_schedule
  sql_statement = "call ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_procedure.update_objects.name}('tasks')"

  allow_overlapping_execution = false
  enabled                     = var.tasks_enabled
}

resource "snowflake_task" "update_stream_objects" {
  depends_on = [
    snowflake_task.update_task_objects,
    snowflake_procedure.update_objects,
    snowflake_warehouse.playground_admin_warehouse
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "UPDATE_PLAY_GROUND_STREAM_OBJECTS_TASK"

  warehouse = snowflake_warehouse.playground_admin_warehouse.name

  after         = [snowflake_task.update_task_objects.name]
  sql_statement = "call ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_procedure.update_objects.name}('streams')"

  allow_overlapping_execution = false
  enabled                     = var.tasks_enabled
}

resource "snowflake_task" "tidy" {
  depends_on = [
    snowflake_task.update_stream_objects,
    snowflake_procedure.update_objects,
    snowflake_warehouse.playground_admin_warehouse
  ]

  database = snowflake_database.play.name
  schema   = snowflake_schema.administration.name
  name     = "PLAYGROUND_TIDY_TASK"

  warehouse = snowflake_warehouse.playground_admin_warehouse.name

  after         = [snowflake_task.update_stream_objects.name]
  sql_statement = "call ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_procedure.tidy_playground.name}(${var.dry_run})"

  allow_overlapping_execution = false
  enabled                     = var.tasks_enabled
}

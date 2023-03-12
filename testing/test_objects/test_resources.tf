########################################################################################
## Test Case 1. Object within max age, no tag - no action | TABLE_1
########################################################################################
resource "snowflake_table" "table_1" {
  database = var.test_db
  schema   = var.test_schema
  name     = "TABLE_1"

  column {
    name     = "id"
    type     = "int"
    nullable = true
  }

  column {
    name     = "identity"
    type     = "NUMBER(38,0)"
    nullable = true
  }

  column {
    name     = "data"
    type     = "text"
    nullable = false
  }

  column {
    name = "DATE"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name    = "extra"
    type    = "VARIANT"
    comment = "extra data"
  }
}

resource "snowflake_table_grant" "table_1_grant" {
  database_name = var.test_db
  schema_name   = var.test_schema
  table_name    = snowflake_table.table_1.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

########################################################################################
## Test Case 2. Object within max age, tag - no action | TABLE_2
########################################################################################
resource "snowflake_table" "table_2" {
  database = var.test_db
  schema   = var.test_schema
  name     = "TABLE_2"

  column {
    name     = "id"
    type     = "int"
    nullable = true
  }

  column {
    name     = "identity"
    type     = "NUMBER(38,0)"
    nullable = true
  }

  column {
    name     = "data"
    type     = "text"
    nullable = false
  }

  column {
    name = "DATE"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name    = "extra"
    type    = "VARIANT"
    comment = "extra data"
  }
}

resource "snowflake_table_grant" "table_2_grant" {
  database_name = var.test_db
  schema_name   = var.test_schema
  table_name    = snowflake_table.table_2.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

resource "snowflake_tag_association" "table_2_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_table.table_2.name
  }
  object_type = "TABLE"
  tag_id      = var.test_tag
  tag_value   = formatdate("YYYY-MM-DD", timeadd(timestamp(), "960h")) # 960h = 40 days
}

########################################################################################
## 3. Object within max age, tag, but tag value not a date - no action | VIEW_1
########################################################################################
resource "snowflake_view" "view_1" {
  depends_on = [
    snowflake_table.table_1
  ]
  database = var.test_db
  schema   = var.test_schema
  name     = "VIEW_1"

  statement = <<-SQL
    select * from table_1
SQL
}

resource "snowflake_view_grant" "view_1_grant" {
  database_name = var.test_db
  schema_name   = var.test_schema
  view_name     = snowflake_view.view_1.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

resource "snowflake_tag_association" "view_1_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_view.view_1.name
  }
  object_type = "TABLE"
  tag_id      = var.test_tag
  tag_value   = "not_a_date"
}

########################################################################################
## Test Case 4. Object within max age, tag, but tag value illegal - re-date tag | VIEW_2
########################################################################################
resource "snowflake_view" "view_2" {
  depends_on = [
    snowflake_table.table_1
  ]
  database = var.test_db
  schema   = var.test_schema
  name     = "VIEW_2"

  statement = <<-SQL
    select * from table_1
SQL
}

resource "snowflake_view_grant" "view_2_grant" {
  database_name = var.test_db
  schema_name   = var.test_schema
  view_name     = snowflake_view.view_2.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

resource "snowflake_tag_association" "view_2_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_view.view_2.name
  }
  object_type = "TABLE"
  tag_id      = var.test_tag
  tag_value   = "9999-12-31"
}

########################################################################################
## Test Case 5. Object within max age, tag, but tag value expired - drop | TASK_1
########################################################################################
resource "snowflake_task" "task_1" {
  depends_on = [
    snowflake_table.table_1
  ]
  database  = var.test_db
  schema    = var.test_schema
  warehouse = var.test_warehouse

  name          = "TASK_1"
  schedule      = "10 MINUTE"
  sql_statement = "select * from table_1"

  user_task_timeout_ms = 10000
  enabled              = false
}

resource "snowflake_task_grant" "task_1_grant" {
  database_name = var.test_db
  schema_name   = var.test_schema
  task_name     = snowflake_task.task_1.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

resource "snowflake_tag_association" "task_1_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_task.task_1.name
  }
  object_type = "TASK"
  tag_id      = var.test_tag
  tag_value   = "2020-01-01"
}

########################################################################################
## Test Case 6. Object outside max age, illegal tag - re-date tag | STREAM_1
########################################################################################
resource "snowflake_stream" "stream_1" {
  depends_on = [
    snowflake_table.table_1
  ]
  database = var.test_db
  schema   = var.test_schema
  name     = "STREAM_1"

  on_table    = "${var.test_db}.${var.test_schema}.${snowflake_table.table_1.name}"
  append_only = false
  insert_only = false
}

resource "snowflake_stream_grant" "stream_1_grant" {
  database_name = var.test_db
  schema_name   = var.test_schema
  stream_name   = snowflake_stream.stream_1.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

resource "snowflake_tag_association" "stream_1_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_stream.stream_1.name
  }
  object_type = "STREAM"
  tag_id      = var.test_tag
  tag_value   = "9999-12-31"
}

########################################################################################
##  Test Case 7. Object outside max age, tag - no action | STAGE_1
#######################################################################################
resource "snowflake_stage" "stage_1" {
  database = var.test_db
  schema   = var.test_schema
  name     = "STAGE_1"
}

resource "snowflake_stage_grant" "stage_1_grant" {
  database_name = var.test_db
  schema_name   = var.test_schema
  stage_name    = snowflake_stage.stage_1.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

resource "snowflake_tag_association" "stage_1_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_stage.stage_1.name
  }
  object_type = "STAGE"
  tag_id      = var.test_tag
  tag_value   = formatdate("YYYY-MM-DD", timeadd(timestamp(), "1200h")) # 1200h = 50 days
}

########################################################################################
## Test Case 8. Object outside max age, no tag - drop | PROC_1
########################################################################################
resource "snowflake_procedure" "proc_1" {
  database = var.test_db
  schema   = var.test_schema
  name     = "PROC_1"

  language = "JAVASCRIPT"
  arguments {
    name = "arg1"
    type = "varchar"
  }
  arguments {
    name = "arg2"
    type = "DATE"
  }
  return_type         = "VARCHAR"
  execute_as          = "CALLER"
  return_behavior     = "IMMUTABLE"
  null_input_behavior = "RETURNS NULL ON NULL INPUT"
  statement           = <<EOT
var X=1
return X
EOT
}

resource "snowflake_procedure_grant" "proc_1_grant" {
  database_name       = var.test_db
  schema_name         = var.test_schema
  procedure_name      = snowflake_procedure.proc_1.name
  argument_data_types = ["varchar", "DATE"]
  privilege           = "OWNERSHIP"
  roles               = ["SYSADMIN"]
}

########################################################################################
## Test Case 9. Object outside max age, tag, but tag value not a date - drop | VIEW_4
########################################################################################
resource "snowflake_view" "view_4" {
  depends_on = [
    snowflake_table.table_1
  ]
  database = var.test_db
  schema   = var.test_schema
  name     = "VIEW_4"

  statement = <<-SQL
    select * from table_1
SQL
}

resource "snowflake_view_grant" "view_4_grant" {
  database_name = var.test_db
  schema_name   = var.test_schema
  view_name     = snowflake_view.view_4.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

resource "snowflake_tag_association" "view_4_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_view.view_4.name
  }
  object_type = "TABLE"
  tag_id      = var.test_tag
  tag_value   = "not_a_date"
}

########################################################################################
## Test Case 10. Object outside max age, tag, but tag value illegal - re-date tag
## | VIEW_5
########################################################################################
resource "snowflake_view" "view_5" {
  depends_on = [
    snowflake_table.table_1
  ]
  database = var.test_db
  schema   = var.test_schema
  name     = "VIEW_5"

  statement = <<-SQL
    select * from table_1
SQL
}

resource "snowflake_view_grant" "view_5_grant" {
  database_name = var.test_db
  schema_name   = var.test_schema
  view_name     = snowflake_view.view_5.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

resource "snowflake_tag_association" "view_5_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_view.view_5.name
  }
  object_type = "TABLE"
  tag_id      = var.test_tag
  tag_value   = "9999-12-31"
}

########################################################################################
## Test Case 11. Object outside max age, tag, but tag value expired - drop | VIEW_6
########################################################################################
resource "snowflake_view" "view_6" {
  depends_on = [
    snowflake_table.table_1
  ]
  database = var.test_db
  schema   = var.test_schema
  name     = "VIEW_6"

  statement = <<-SQL
    select * from table_1
SQL
}

resource "snowflake_view_grant" "view_6_grant" {
  database_name = var.test_db
  schema_name   = var.test_schema
  view_name     = snowflake_view.view_6.name

  privilege = "OWNERSHIP"
  roles     = ["SYSADMIN"]
}

resource "snowflake_tag_association" "view_6_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_view.view_6.name
  }
  object_type = "TABLE"
  tag_id      = var.test_tag
  tag_value   = "2020-01-01"
}

########################################################################################
## Test Case 12. No permission to see / drop object - no action & not logged | TABLE_3
########################################################################################

resource "snowflake_table" "table_3" {
  database = var.test_db
  schema   = var.test_schema
  name     = "TABLE_3"

  column {
    name     = "id"
    type     = "int"
    nullable = true
  }

  column {
    name     = "identity"
    type     = "NUMBER(38,0)"
    nullable = true
  }
}

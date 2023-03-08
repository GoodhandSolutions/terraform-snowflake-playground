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

# Illegal tag
resource "snowflake_tag_association" "table_1_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_table.table_1.name
  }
  object_type = "TABLE"
  tag_id      = var.test_tag
  tag_value   = formatdate("YYYY-MM-DD", timeadd(timestamp(), "960h")) # 960h = 40 days
}

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

# Invalid tag
resource "snowflake_tag_association" "view_1_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_view.view_1.name
  }
  object_type = "TABLE"
  tag_id      = var.test_tag
  tag_value   = "9999-12-31"
}

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

# Expired tag
resource "snowflake_tag_association" "task_1_tag" {
  object_identifier {
    database = var.test_db
    schema   = var.test_schema
    name     = snowflake_task.task_1.name
  }
  object_type = "TASK"
  tag_id      = var.test_tag
  tag_value   = formatdate("YYYY-MM-DD", timeadd(timestamp(), "-960h")) # 960h = 40 days
}

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

# Valid tag
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

# Should give a permission denied error when trying to drop
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
}

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

# Valid tag
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

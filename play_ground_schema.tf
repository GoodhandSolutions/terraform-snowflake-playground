###############################################################
# Playground Schema
###############################################################
resource "snowflake_schema" "ground" {
  depends_on = [
    snowflake_database.play
  ]

  database = snowflake_database.play.name
  name     = var.playground_schema_name

  data_retention_days = var.data_retention_time
  is_transient        = false
  is_managed          = true
}

resource "snowflake_schema_grant" "play_ground_grant_usage" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "USAGE"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

###############################################################
# Play Ground Schema Create Grants
###############################################################
resource "snowflake_schema_grant" "play_ground_grant_external_table" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE EXTERNAL TABLE"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_file_format" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE FILE FORMAT"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_function" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE FUNCTION"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_masking_policy" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE MASKING POLICY"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_materialized_view" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE MATERIALIZED VIEW"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_pipe" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE PIPE"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_procedure" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE PROCEDURE"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_row_policy" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE ROW ACCESS POLICY"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_sequence" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE SEQUENCE"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_stage" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE STAGE"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_stream" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE STREAM"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_table" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE TABLE"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_task" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE TASK"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_temporary_table" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE TEMPORARY TABLE"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

resource "snowflake_schema_grant" "play_ground_grant_view" {
  depends_on = [
    snowflake_schema.ground
  ]

  database_name = snowflake_database.play.name
  schema_name   = snowflake_schema.ground.name

  privilege = "CREATE VIEW"
  roles     = ["PUBLIC"]

  with_grant_option = false
}

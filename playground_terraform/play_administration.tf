###############################################################
# Schema Definition
###############################################################
resource "snowflake_schema" "administration" {
    depends_on = [
      snowflake_database.play
    ]

    database = "${snowflake_database.play.name}"
    name = var.playground_admin_schema_name
    
    is_transient = false
    is_managed = true
}

resource "snowflake_schema_grant" "play_administration_grant_usage" {
    depends_on = [
      snowflake_schema.administration
    ]

    database_name = "${snowflake_database.play.name}"
    schema_name = "${snowflake_schema.administration.name}"

    privilege = "USAGE"
    roles = ["PUBLIC"]

    with_grant_option = false
}

###############################################################
# Expiration tag definitions and views
###############################################################
resource "snowflake_tag" "expiry_date_tag" {
    depends_on = [
      snowflake_schema.administration
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "EXPIRY_DATE"

    comment = "Tag values must be in the form of YYYY-MM-DD."
}

resource "snowflake_tag_grant" "expiry_date_apply_grant" {
    depends_on = [
      snowflake_tag.expiry_date_tag
    ]

    database_name = "${snowflake_database.play.name}"
    schema_name = "${snowflake_schema.administration.name}"
    tag_name = "EXPIRY_DATE"

    roles = ["PUBLIC"]
    privilege = "APPLY"
}

resource "snowflake_view" "object_tags" {
    depends_on = [
      snowflake_schema.administration
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "OBJECT_TAGS"

    statement = <<-SQL
        SELECT 
            object_database,
            object_schema,
            object_name,
            column_name,
            domain,
            TRY_TO_DATE(MAX(DECODE(tag_name, 'EXPIRY_DATE', tag_value, NULL))::varchar) AS expiry_date
        FROM
            SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES
        WHERE tag_database = 'ACCOUNT_OBJECTS'
            AND tag_schema = 'TAGS'
            AND object_deleted IS null
        GROUP BY 1,2,3,4,5;
    SQL
}

resource "snowflake_view_grant" "select_object_tags_grant" {
    depends_on = [
        snowflake_view.object_tags
    ]

    database_name = "${snowflake_database.play.name}"
    schema_name = "${snowflake_schema.administration.name}"
    view_name = "${snowflake_view.object_tags.name}"

    privilege = "SELECT"
    roles = ["PUBLIC"]

    with_grant_option = false
}

###############################################################
# View for determining object age
###############################################################
#TODO: Up-date to include all object types, not just tables.
resource "snowflake_view" "table_ages" {
    depends_on = [
        snowflake_schema.administration,
        snowflake_schema.ground,
        snowflake_view.object_tags
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "TABLE_AGES"

    statement = <<-SQL
        SELECT
            tbls.table_catalog AS TABLE_DATABASE,
            tbls.table_schema AS TABLE_SCHEMA,
            tbls.table_name AS TABLE_NAME,
            DATEDIFF(day, tbls.created, CURRENT_DATE) AS DAYS_SINCE_CREATION,
            DATEDIFF(day, tbls.last_altered, CURRENT_DATE) AS DAYS_SINCE_LAST_ALTERATION,
            tgs.EXPIRY_DATE AS EXPIRY_DATE,
            tbls.table_owner AS TABLE_OWNER,
            tbls.table_type AS TABLE_TYPE
        FROM ${snowflake_database.play.name}.information_schema.tables tbls
        LEFT OUTER JOIN "${snowflake_database.play.name}"."${snowflake_schema.administration.name}"."${snowflake_view.object_tags.name}" tgs
            ON tgs.object_database = tbls.table_catalog
            AND tgs.object_schema = tbls.table_schema
            AND tgs.object_name = tbls.table_name
        WHERE
            (tgs.domain='TABLE' OR tgs.domain IS NULL)
            AND tbls.table_catalog = '"${snowflake_database.play.name}"'
            AND tbls.table_schema = '"${snowflake_schema.ground.name}"'
            AND tbls.table_schema != 'INFORMATION_SCHEMA'
        ;
    SQL
}

resource "snowflake_view_grant" "select_table_ages_grant" {
    depends_on = [
        snowflake_view.table_ages
    ]

    database_name = "${snowflake_database.play.name}"
    schema_name = "${snowflake_schema.administration.name}"
    view_name = "${snowflake_view.table_ages.name}"

    privilege = "SELECT"
    roles = ["PUBLIC"]

    with_grant_option = false
}

###############################################################
# Log table
###############################################################
resource "snowflake_table" "log_table" {
    depends_on = [
        snowflake_view.object_tags
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "LOG"

    change_tracking = true

    column {
        name = "event_time"
        type = "TIMESTAMP_TZ"
        nullable = false
    }

    column {
        name = "record"
        type = "VARIANT"
    }
}

resource "snowflake_object_parameter" "log_table_data_retention" {
    depends_on = [
        snowflake_table.log_table
    ]

    object_identifier {
        database = "${snowflake_database.play.name}"
        schema = "${snowflake_schema.administration.name}"
        name = "${snowflake_table.log_table.name}"
    }

    key = "DATA_RETENTION_TIME_IN_DAYS"
    value = "31"
    object_type = "TABLE"
}

###############################################################
# Clean-up Procedure
###############################################################
resource "snowflake_procedure" "tidy_playground" {
    depends_on = [
      snowflake_table.log_table,
      snowflake_view.table_ages,
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "TIDY_PLAYGROUND"

    language = "JAVASCRIPT"
    return_type = "string"
    execute_as = "OWNER"

    statement = file("./tidy_playground.js")
}

###############################################################
# Task to execute clean-up
###############################################################
resource "snowflake_warehouse" "playground_admin_warehouse" {
    name = var.playground_warehouse_name
    warehouse_size = var.playground_warehouse_size

    auto_resume = true
    auto_suspend = 59
    initially_suspended = true

    max_cluster_count = 1
    min_cluster_count = 1
    
    warehouse_type = "STANDARD"
}

resource "snowflake_task" "tidy_task" {
    depends_on = [
        snowflake_procedure.tidy_playground,
        snowflake_warehouse.playground_admin_warehouse
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "playground_tidy_task"

    warehouse = "${snowflake_warehouse.playground_admin_warehouse.name}"
    schedule = "USING CRON 0 3 * * * UTC"
    sql_statement = "call ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_procedure.tidy_playground.name}()"

    allow_overlapping_execution = false
    enabled = true
}
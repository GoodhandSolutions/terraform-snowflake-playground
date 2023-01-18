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

    database = var.expiry_date_tag_database
    schema = var.expiry_date_tag_schema
    name = var.expiry_date_tag_name

    comment = "Tag values must be in the form of YYYY-MM-DD."
}

resource "snowflake_tag_grant" "expiry_date_apply_grant" {
    depends_on = [
      snowflake_tag.expiry_date_tag
    ]

    database_name = var.expiry_date_tag_database
    schema_name = var.expiry_date_tag_schema
    tag_name = var.expiry_date_tag_name

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
    domain,
    TRY_TO_DATE(MAX(DECODE(tag_name, 'EXPIRY_DATE', tag_value, NULL))::varchar) AS expiry_date
FROM
    snowflake.account_usage.tag_references
WHERE tag_database = '${var.expiry_date_tag_database}'
    AND tag_schema = '${var.expiry_date_tag_schema}'
    AND object_deleted IS null
GROUP BY 1,2,3,4;
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
# Handle objects only available via 'SHOW'
###############################################################
resource "snowflake_table" "tasks" {
    depends_on = [
        snowflake_schema.administration
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "TASKS"

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

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "STREAMS"

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
    depends_on = [
      snowflake_table.tasks,
      snowflake_table.streams,
      snowflake_schema.ground
    ]
    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "UPDATE_OBJECTS"

    language = "SQL"
    arguments {
        name = "object_type"
        type = "varchar"
    }

    return_type = "varchar"
    execute_as = "OWNER"
    statement = <<EOT
DECLARE
    invalid_object_type exception (-20002, 'Invalid Object Type');
BEGIN
    IF (UPPER(object_type) = 'TASKS') THEN

        execute immediate 'TRUNCATE TABLE IF EXISTS ${snowflake_database.play.name}.${snowflake_schema.administration.name}.tasks';
        execute immediate 'SHOW TASKS IN SCHEMA ${snowflake_database.play.name}.${snowflake_schema.ground.name}';
        INSERT INTO ${snowflake_database.play.name}.${snowflake_schema.administration.name}.tasks (
            SELECT 
                "created_on" AS created_on,
                "name" AS name,
                "id" AS id,
                "database_name" AS database_name,
                "schema_name" AS schema_name,
                "owner" AS owner,
                "comment" AS comment,
                "warehouse" AS warehouse,
                "schedule" AS schedule,
                "predecessors" AS predecessors,
                "state" AS state,
                "definition" AS definition,
                "condition" AS condition,
                "allow_overlapping_execution" AS allow_overlapping_execution,
                "error_integration" AS error_integration,
                "last_committed_on" AS last_committed_on,
                "last_suspended_on" AS last_suspended_on
            FROM
                table(result_scan(last_query_id()))
        );

        return 'Updated ${snowflake_database.play.name}.${snowflake_schema.administration.name}.tasks to contain the latest list of tasks.';
        
    ELSEIF (UPPER(object_type) = 'STREAMS') THEN
    
        execute immediate 'TRUNCATE TABLE IF EXISTS ${snowflake_database.play.name}.${snowflake_schema.administration.name}.streams';
        execute immediate 'SHOW STREAMS IN SCHEMA ${snowflake_database.play.name}.${snowflake_schema.ground.name}';
        INSERT INTO ${snowflake_database.play.name}.${snowflake_schema.administration.name}.streams (
            SELECT 
                "created_on" AS created_on, 
                "name" AS name,
                "database_name" AS database_name,
                "schema_name" AS schema_name,
                "owner" AS owner,
                "comment" AS comment,
                "table_name" AS table_name,
                "source_type" AS source_type,
                "base_tables" AS base_tables,
                "type" AS type,
                "stale" AS stale,
                "mode" AS mode,
                "stale_after" AS stale_after,
                "invalid_reason" AS invalid_reason
            FROM
                table(result_scan(last_query_id()))
        );
        
        return 'Updated ${snowflake_database.play.name}.${snowflake_schema.administration.name}.STREAMS to contain the latest list of tasks.';
        
    ELSE
        raise invalid_object_type;
    END IF;
END
;
EOT
}

###############################################################
# Normalize Procedure Names
###############################################################

resource "snowflake_function" "normalize_proc_names" {
    depends_on = [
      snowflake_schema.administration
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "NORMALIZE_PROC_NAMES"

    arguments {
        name = "name"
        type = "string"
    }

    arguments {
        name = "source"
        type = "string"
    }

    arguments {
        name = "arguments"
        type = "string"
    }

    return_type = "string"

    language = "python"
    runtime_version = "3.8"
    handler = "main"
    statement = file("./code/func_ normalize_proc_names.py")
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

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "OBJECT_AGES"

    // This doesn't include the following objects, because they cannot be tagged:
    // tags, file formats, functions, masking policies, row access policies, sequences

    // You can't have views, materialized views, tables or ext tables with the same name.
    // These objects can therefore all be treated as tables.

    statement = <<-SQL
WITH
tbls AS (
    SELECT
        objects.table_catalog AS object_database,
        objects.table_schema AS object_schema,
        objects.table_name AS object_name,
        UPPER(REPLACE(objects.table_type, ' ', '_')) AS object_type,
        'TABLE' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type = 'BASE_TABLE' THEN 'TABLE'
            WHEN object_type in ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type in ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(day, objects.created, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(day, objects.last_altered, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.table_owner AS object_owner
    FROM
        ${snowflake_database.play.name}.information_schema.tables objects 
    LEFT OUTER JOIN ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_tags.name} tgs 
        ON tgs.object_database = objects.table_catalog
        AND tgs.object_schema = objects.table_schema
        AND tgs.object_name = objects.table_name
    WHERE
        (
            tgs.domain = 'TABLE'
            OR tgs.domain IS NULL
        )
        AND objects.table_catalog = '${snowflake_database.play.name}' 
        AND objects.table_schema = 'GROUND' 
        AND objects.table_schema != 'INFORMATION_SCHEMA'
),
ext_tbls AS (
    SELECT
        objects.table_catalog AS object_database,
        objects.table_schema AS object_schema,
        objects.table_name AS object_name,
        'EXTERNAL_TABLE' AS object_type,
        'TABLE' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type = 'BASE_TABLE' THEN 'TABLE'
            WHEN object_type in ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type in ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(day, objects.created, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(day, objects.last_altered, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.table_owner AS object_owner
    FROM
        ${snowflake_database.play.name}.information_schema.external_tables objects 
    LEFT OUTER JOIN ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_tags.name} tgs 
        ON tgs.object_database = objects.table_catalog
        AND tgs.object_schema = objects.table_schema
        AND tgs.object_name = objects.table_name
    WHERE
        (
            tgs.domain = 'TABLE'
            OR tgs.domain IS NULL
        )
        AND objects.table_catalog = '${snowflake_database.play.name}' 
        AND objects.table_schema = '${snowflake_schema.ground.name}' 
        AND objects.table_schema != 'INFORMATION_SCHEMA'
),
pipes AS (
    SELECT
        objects.pipe_catalog AS object_catalog,
        objects.pipe_schema AS object_schema,
        objects.pipe_name AS object_name,
        'PIPE' AS object_type,
        'PIPE' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type = 'BASE_TABLE' THEN 'TABLE'
            WHEN object_type in ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type in ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(day, objects.created, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(day, objects.last_altered, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.pipe_owner as object_owner
    FROM
        ${snowflake_database.play.name}.information_schema.pipes objects 
    LEFT OUTER JOIN ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_tags.name} tgs 
        ON tgs.object_database = objects.pipe_catalog
        AND tgs.object_schema = objects.pipe_schema
        AND tgs.object_name = objects.pipe_name
    WHERE
        (
            tgs.domain = 'PIPE'
            OR tgs.domain IS NULL
        )
        AND objects.pipe_catalog = '${snowflake_database.play.name}' 
        AND objects.pipe_schema = '${snowflake_schema.ground.name}' 
        AND objects.pipe_schema != 'INFORMATION_SCHEMA'
),
stages AS (
    SELECT
        objects.stage_catalog AS object_catalog,
        objects.stage_schema AS object_schema,
        objects.stage_name AS object_name,
        UPPER(REPLACE(objects.stage_type, ' ', '_')) AS object_type,
        'STAGE' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type = 'BASE_TABLE' THEN 'TABLE'
            WHEN object_type in ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type in ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(day, objects.created, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(day, objects.last_altered, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.stage_owner as object_owner
    FROM
        ${snowflake_database.play.name}.information_schema.stages objects 
    LEFT OUTER JOIN ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_tags.name} tgs 
        ON tgs.object_database = objects.stage_catalog
        AND tgs.object_schema = objects.stage_schema
        AND tgs.object_name = objects.stage_name
    WHERE
        (
            tgs.domain = 'STAGE'
            OR tgs.domain IS NULL
        )
        AND objects.stage_catalog = '${snowflake_database.play.name}' 
        AND objects.stage_schema = '${snowflake_schema.ground.name}' 
        AND objects.stage_schema != 'INFORMATION_SCHEMA'
),
proc_tags AS (
    SELECT
        object_database,
        object_schema,
        NORMALIZE_PROC_NAMES(object_name, 'TAG_REFERENCES', '') AS object_name,
        domain,
        expiry_date
    FROM
        ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_tags.name}
    WHERE
        domain = 'PROCEDURE'
        OR domain IS NULL
),
procedures AS (
    SELECT
        objects.procedure_catalog AS object_catalog,
        objects.procedure_schema AS object_schema,
        NORMALIZE_PROC_NAMES(objects.procedure_name, 'INFORMATION_SCHEMA', objects.argument_signature) AS object_name,
        'PROCEDURE' AS object_type,
        'PROCEDURE' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type = 'BASE_TABLE' THEN 'TABLE'
            WHEN object_type in ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type in ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(day, objects.created, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(day, objects.last_altered, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.procedure_owner as object_owner
    FROM
        ${snowflake_database.play.name}.information_schema.procedures objects 
    LEFT OUTER JOIN proc_tags tgs 
        ON tgs.object_database = objects.procedure_catalog
        AND tgs.object_schema = objects.procedure_schema
        AND tgs.object_name = object_name
    WHERE
        objects.procedure_catalog = '${snowflake_database.play.name}' 
        AND objects.procedure_schema = '${snowflake_schema.ground.name}' 
        AND objects.procedure_schema != 'INFORMATION_SCHEMA'
),
streams AS (
    SELECT
        objects.database_name AS object_catalog,
        objects.schema_name AS object_schema,
        objects.name AS object_name,
        'STREAM' AS object_type,
        'STREAM' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type = 'BASE_TABLE' THEN 'TABLE'
            WHEN object_type in ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type in ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(day, objects.created_on, CURRENT_DATE) AS days_since_creation,
        NULL AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.owner as object_owner
    FROM
        ${snowflake_database.play.name}.${snowflake_schema.administration.name}.streams objects 
    LEFT OUTER JOIN ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_tags.name} tgs 
        ON tgs.object_database = objects.database_name
        AND tgs.object_schema = objects.schema_name
        AND tgs.object_name = objects.name
    WHERE
        (
            tgs.domain = 'STREAM'
            OR tgs.domain IS NULL
        )
        AND objects.database_name = '${snowflake_database.play.name}' 
        AND objects.schema_name = '${snowflake_schema.ground.name}' 
        AND objects.schema_name != 'INFORMATION_SCHEMA'
),
tasks AS (
    SELECT
        objects.database_name AS object_catalog,
        objects.schema_name AS object_schema,
        objects.name AS object_name,
        'TASK' AS object_type,
        'TASK' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type = 'BASE_TABLE' THEN 'TABLE'
            WHEN object_type in ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type in ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(day, objects.created_on, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(day, objects.last_committed_on, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.owner as object_owner
    FROM
        ${snowflake_database.play.name}.${snowflake_schema.administration.name}.tasks objects 
    LEFT OUTER JOIN ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_tags.name} tgs 
        ON tgs.object_database = objects.database_name
        AND tgs.object_schema = objects.schema_name
        AND tgs.object_name = objects.name
    WHERE
        (
            tgs.domain = 'TASK'
            OR tgs.domain IS NULL
        )
        AND objects.database_name = '${snowflake_database.play.name}' 
        AND objects.schema_name = '${snowflake_schema.ground.name}' 
        AND objects.schema_name != 'INFORMATION_SCHEMA'
)
SELECT * FROM tbls
UNION
SELECT * FROM ext_tbls
UNION
SELECT * FROM pipes
UNION
SELECT * FROM stages
UNION
SELECT * FROM procedures
UNION
SELECT * FROM streams
UNION
SELECT * FROM tasks
;
SQL
}

resource "snowflake_view_grant" "select_object_ages_grant" {
    depends_on = [
        snowflake_view.object_ages
    ]

    database_name = "${snowflake_database.play.name}"
    schema_name = "${snowflake_schema.administration.name}"
    view_name = "${snowflake_view.object_ages.name}"

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
        name = "EVENT_TIME"
        type = "TIMESTAMP_TZ(9)"
        nullable = false
    }

    column {
        name = "RECORD"
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
      snowflake_view.object_ages,
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "TIDY_PLAYGROUND"

    language = "SQL"
    return_type = "VARCHAR(16777216)"
    arguments {
        name = "dry_run"
        type = "boolean"
    }
    execute_as = "OWNER"

    statement = <<-SQL
DECLARE
    cs cursor for
        SELECT
            OBJECT_DATABASE,
            OBJECT_SCHEMA,
            OBJECT_NAME,
            OBJECT_TYPE,
            SQL_OBJECT_TYPE,
            OBJECT_DOMAIN,
            DAYS_SINCE_CREATION,
            DAYS_SINCE_LAST_ALTERATION,
            EXPIRY_DATE,
            OBJECT_OWNER
        FROM
            ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_ages.name}
        WHERE
            (
                DAYS_SINCE_CREATION > ${var.max_object_age_without_tag}
                AND EXPIRY_DATE IS NULL
            ) OR (
                EXPIRY_DATE < CURRENT_DATE()
            )
        ORDER BY DAYS_SINCE_CREATION DESC
    ;

    drop_reason VARCHAR;
    log_record VARCHAR;
    sql_cmd VARCHAR;
    result VARCHAR DEFAULT '';
    rs RESULTSET;
BEGIN
    OPEN cs;
    
    FOR record IN cs DO
        drop_reason := 'Expiry date for object has passed';
        IF (record.expiry_date IS NULL) THEN
            drop_reason := 'Table older than ${var.max_object_age_without_tag} days, with no expiry date tag.';
        END IF;

        sql_cmd := 'DROP ' || record.sql_object_type || ' "' || record.object_database || '"."' || record.object_schema || '"."' || record.object_name || '";';

        IF (dry_run) THEN
            rs := (SELECT NULL);
        ELSE
            rs := (EXECUTE IMMEDIATE :sql_cmd);
        END IF;

        let cur cursor for rs;
        open cur;
        fetch cur into result;

        log_record := '{"sql":"' || REPLACE(sql_cmd,'"', '\\"') || '",
                        "action":"DROP_' || REPLACE(record.sql_object_type, ' ', '_') || '",
                        "reason":"' || drop_reason || '",
                        "justification":{
                            "age":"' || record.days_since_creation || '",
                            "days_since_last_alteration":' || record.days_since_last_alteration || ',
                            "expiry_date":' || IFF(record.expiry_date IS NULL, 'null', '"' || record.expiry_date::varchar || '"') || '},
                        "result":' || IFF(result IS NULL, 'null', '"' || result || '"') || '}';

        INSERT INTO ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_table.log_table.name} (event_time, record) SELECT CURRENT_TIMESTAMP(), PARSE_JSON(:log_record);
    END FOR;
END;
SQL
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

resource "snowflake_task" "update_task_objects" {
    depends_on = [
        snowflake_procedure.update_objects,
        snowflake_warehouse.playground_admin_warehouse
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "UPDATE_PLAY_GROUND_TASK_OBJECTS_TASK"

    warehouse = "${snowflake_warehouse.playground_admin_warehouse.name}"
    # Given the playground relies on SNOWFLAKE.ACCOUNT_USAGE which can be delayed by up to 3 hours,
    # running at 0300 means that even with delays to reading tags, the behaviour should be as expected.
    schedule = "USING CRON 0 3 * * * UTC"
    sql_statement = "call ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_procedure.update_objects.name}('tasks')"

    allow_overlapping_execution = false
    enabled = true
}

resource "snowflake_task" "update_stream_objects" {
    depends_on = [
        snowflake_task.update_task_objects,
        snowflake_procedure.update_objects,
        snowflake_warehouse.playground_admin_warehouse
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "UPDATE_PLAY_GROUND_STREAM_OBJECTS_TASK"

    warehouse = "${snowflake_warehouse.playground_admin_warehouse.name}"

    after = [snowflake_task.update_task_objects.name]
    sql_statement = "call ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_procedure.tidy_playground.name}('streams')"

    allow_overlapping_execution = false
    enabled = true
}

resource "snowflake_task" "tidy" {
    depends_on = [
        snowflake_task.update_stream_objects,
        snowflake_procedure.update_objects,
        snowflake_warehouse.playground_admin_warehouse
    ]

    database = "${snowflake_database.play.name}"
    schema = "${snowflake_schema.administration.name}"
    name = "PLAYGROUND_TIDY_TASK"

    warehouse = "${snowflake_warehouse.playground_admin_warehouse.name}"

    after = [snowflake_task.update_stream_objects.name]
    sql_statement = "call ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_procedure.tidy_playground.name}()"

    allow_overlapping_execution = false
    enabled = true
}
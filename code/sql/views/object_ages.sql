WITH
tbls AS (
    SELECT --noqa: L034
        objects.table_catalog AS object_database,
        objects.table_schema AS object_schema,
        '"' || objects.table_name || '"' AS object_name,
        UPPER(REPLACE(objects.table_type, ' ', '_')) AS object_type,
        'TABLE' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type IN ('BASE_TABLE', 'EXTERNAL_TABLE') THEN 'TABLE'
            WHEN object_type IN ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type IN ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(DAY, objects.created, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(DAY, objects.last_altered, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.table_owner AS object_owner
    FROM
        ${playground_db_name}.information_schema.tables objects
    LEFT OUTER JOIN ${object_tags_view_path} tgs ON
        tgs.object_database = objects.table_catalog
        AND tgs.object_schema = objects.table_schema
        AND tgs.object_name = objects.table_name
    WHERE -- noqa: L003
        ( -- noqa: L003
            tgs.domain = 'TABLE'
            OR tgs.domain IS NULL
        )
        AND objects.table_catalog = '${playground_db_name}'
        AND objects.table_schema = '${playground_schema_name}'
        AND objects.table_schema != 'INFORMATION_SCHEMA'
),

ext_tbls AS (
    SELECT
        objects.table_catalog AS object_database,
        objects.table_schema AS object_schema,
        '"' || objects.table_name || '"' AS object_name,
        'EXTERNAL_TABLE' AS object_type,
        'TABLE' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type IN ('BASE_TABLE', 'EXTERNAL_TABLE') THEN 'TABLE'
            WHEN object_type IN ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type IN ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(DAY, objects.created, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(DAY, objects.last_altered, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.table_owner AS object_owner
    FROM
        ${playground_db_name}.information_schema.external_tables objects
    LEFT OUTER JOIN ${object_tags_view_path} tgs ON
        tgs.object_database = objects.table_catalog
        AND tgs.object_schema = objects.table_schema
        AND tgs.object_name = objects.table_name
    WHERE -- noqa: L003
        ( -- noqa: L003
            tgs.domain = 'TABLE'
            OR tgs.domain IS NULL
        )
        AND objects.table_catalog = '${playground_db_name}'
        AND objects.table_schema = '${playground_schema_name}'
        AND objects.table_schema != 'INFORMATION_SCHEMA'
),

pipes AS (
    SELECT
        objects.pipe_catalog AS object_catalog,
        objects.pipe_schema AS object_schema,
        '"' || objects.pipe_name || '"' AS object_name,
        'PIPE' AS object_type,
        'PIPE' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type IN ('BASE_TABLE', 'EXTERNAL_TABLE') THEN 'TABLE'
            WHEN object_type IN ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type IN ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(DAY, objects.created, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(DAY, objects.last_altered, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.pipe_owner AS object_owner
    FROM
        ${playground_db_name}.information_schema.pipes objects
    LEFT OUTER JOIN ${object_tags_view_path} tgs ON
        tgs.object_database = objects.pipe_catalog
        AND tgs.object_schema = objects.pipe_schema
        AND tgs.object_name = objects.pipe_name
    WHERE -- noqa: L003
        ( -- noqa: L003
            tgs.domain = 'PIPE'
            OR tgs.domain IS NULL
        )
        AND objects.pipe_catalog = '${playground_db_name}'
        AND objects.pipe_schema = '${playground_schema_name}'
        AND objects.pipe_schema != 'INFORMATION_SCHEMA'
),

stages AS (
    SELECT
        objects.stage_catalog AS object_catalog,
        objects.stage_schema AS object_schema,
        '"' || objects.stage_name || '"' AS object_name,
        UPPER(REPLACE(objects.stage_type, ' ', '_')) AS object_type,
        'STAGE' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type IN ('BASE_TABLE', 'EXTERNAL_TABLE') THEN 'TABLE'
            WHEN object_type IN ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type IN ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(DAY, objects.created, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(DAY, objects.last_altered, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.stage_owner AS object_owner
    FROM
        ${playground_db_name}.information_schema.stages objects
    LEFT OUTER JOIN ${object_tags_view_path} tgs ON
        tgs.object_database = objects.stage_catalog
        AND tgs.object_schema = objects.stage_schema
        AND tgs.object_name = objects.stage_name
    WHERE -- noqa: L003
        ( -- noqa: L003
            tgs.domain = 'STAGE'
            OR tgs.domain IS NULL
        )
        AND objects.stage_catalog = '${playground_db_name}'
        AND objects.stage_schema = '${playground_schema_name}'
        AND objects.stage_schema != 'INFORMATION_SCHEMA'
),

-- Ignore L045 (proc_tags is used in the next CTE)
proc_tags AS ( --noqa: L045
    SELECT
        object_database,
        object_schema,
        NORMALIZE_PROC_NAMES(object_name, 'TAG_REFERENCES', '') AS object_name,
        domain,
        expiry_date
    FROM
        ${object_tags_view_path} --noqa
    WHERE
        domain = 'PROCEDURE'
        OR domain IS NULL
),

procedures AS (
    SELECT
        objects.procedure_catalog AS object_catalog,
        objects.procedure_schema AS object_schema,
        NORMALIZE_PROC_NAMES(
            objects.procedure_name,
            'INFORMATION_SCHEMA',
            objects.argument_signature) AS object_name,
        'PROCEDURE' AS object_type,
        'PROCEDURE' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type IN ('BASE_TABLE', 'EXTERNAL_TABLE') THEN 'TABLE'
            WHEN object_type IN ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type IN ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(DAY, objects.created, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(DAY, objects.last_altered, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.procedure_owner AS object_owner
    FROM
        ${playground_db_name}.information_schema.procedures objects
    LEFT OUTER JOIN proc_tags tgs ON
        tgs.object_database = objects.procedure_catalog
        AND tgs.object_schema = objects.procedure_schema
        AND tgs.object_name = object_name
    WHERE -- noqa: L003
        objects.procedure_catalog = '${playground_db_name}' -- noqa: L003
        AND objects.procedure_schema = '${playground_schema_name}' -- noqa: L003
        AND objects.procedure_schema != 'INFORMATION_SCHEMA' -- noqa: L003
),

streams AS (
    SELECT
        objects.database_name AS object_catalog,
        objects.schema_name AS object_schema,
        '"' || objects.name || '"' AS object_name,
        'STREAM' AS object_type,
        'STREAM' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type IN ('BASE_TABLE', 'EXTERNAL_TABLE') THEN 'TABLE'
            WHEN object_type IN ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type IN ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(DAY, objects.created_on, CURRENT_DATE) AS days_since_creation,
        NULL AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.owner AS object_owner
    FROM
        ${playground_db_name}.${playground_administration_schema_name}.streams objects
    LEFT OUTER JOIN ${object_tags_view_path} tgs ON
        tgs.object_database = objects.database_name
        AND tgs.object_schema = objects.schema_name
        AND tgs.object_name = objects.name
    WHERE -- noqa: L003
        ( -- noqa: L003
            tgs.domain = 'STREAM'
            OR tgs.domain IS NULL
        )
        AND objects.database_name = '${playground_db_name}'
        AND objects.schema_name = '${playground_schema_name}'
        AND objects.schema_name != 'INFORMATION_SCHEMA'
),

tasks AS (
    SELECT
        objects.database_name AS object_catalog,
        objects.schema_name AS object_schema,
        '"' || objects.name || '"' AS object_name,
        'TASK' AS object_type,
        'TASK' AS object_domain,
        tgs.domain AS tag_domain,
        CASE
            WHEN object_type IN ('BASE_TABLE', 'EXTERNAL_TABLE') THEN 'TABLE'
            WHEN object_type IN ('VIEW', 'MATERIALIZED_VIEW') THEN 'VIEW'
            WHEN object_type IN ('INTERNAL_NAMED', 'EXTERNAL_NAMED') THEN 'STAGE'
            ELSE object_type
        END AS sql_object_type,
        DATEDIFF(DAY, objects.created_on, CURRENT_DATE) AS days_since_creation,
        DATEDIFF(DAY, objects.last_committed_on, CURRENT_DATE) AS days_since_last_alteration,
        TRY_TO_DATE(tgs.expiry_date) AS expiry_date,
        objects.owner AS object_owner
    FROM
        ${playground_db_name}.${playground_administration_schema_name}.tasks objects
    LEFT OUTER JOIN ${object_tags_view_path} tgs ON
        tgs.object_database = objects.database_name
        AND tgs.object_schema = objects.schema_name
        AND tgs.object_name = objects.name
    WHERE -- noqa: L003
        ( -- noqa: L003
            tgs.domain = 'TASK'
            OR tgs.domain IS NULL
        )
        AND objects.database_name = '${playground_db_name}'
        AND objects.schema_name = '${playground_schema_name}'
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
SELECT * FROM tasks;

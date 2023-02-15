DECLARE
    invalid_object_type exception (-20002, 'Invalid Object Type');
BEGIN
    IF (UPPER(object_type) = 'TASKS') THEN

        execute immediate 'TRUNCATE TABLE IF EXISTS ${playground_db}.${playground_administration_schema}.tasks';
        execute immediate 'SHOW TASKS IN SCHEMA ${playground_db}.${playground_schema}';
        INSERT INTO ${playground_db}.${playground_administration_schema}.tasks (
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

        return 'Updated ${playground_db}.${playground_administration_schema}.tasks to contain the latest list of tasks.';

    ELSEIF (UPPER(object_type) = 'STREAMS') THEN

        execute immediate 'TRUNCATE TABLE IF EXISTS ${playground_db}.${playground_administration_schema}.streams';
        execute immediate 'SHOW STREAMS IN SCHEMA ${playground_db}.${playground_schema}';
        INSERT INTO ${playground_db}.${playground_administration_schema}.streams (
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

        return 'Updated ${playground_db}.${playground_administration_schema}.STREAMS to contain the latest list of tasks.';

    ELSE
        raise invalid_object_type;
    END IF;
EXCEPTION
    WHEN invalid_object_type THEN
        RETURN OBJECT_CONSTRUCT('Error type', 'INVALID_OBJECT_TYPE',
                                'Error message', 'Procedure only supports object types of \'STREAMS\' or \'TASKS\'',
                                'SQLCODE', sqlcode,
                                'SQLERRM', sqlerrm,
                                'SQLSTATE', sqlstate);
    WHEN STATEMENT_ERROR THEN
        RETURN OBJECT_CONSTRUCT('Error type', 'STATEMENT_ERROR',
                                'SQLCODE', sqlcode,
                                'SQLERRM', sqlerrm,
                                'SQLSTATE', sqlstate);
    WHEN EXPRESSION_ERROR THEN
        RETURN OBJECT_CONSTRUCT('Error type', 'EXPRESSION_ERROR',
                                'SQLCODE', sqlcode,
                                'SQLERRM', sqlerrm,
                                'SQLSTATE', sqlstate);
    WHEN OTHER THEN
        RETURN OBJECT_CONSTRUCT('Error type', 'OTHER_ERROR',
                                'SQLCODE', sqlcode,
                                'SQLERRM', sqlerrm,
                                'SQLSTATE', sqlstate);
END
;

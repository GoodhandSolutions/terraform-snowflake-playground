DECLARE
    expired_objects CURSOR FOR
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
            ${object_ages_view_path}
        WHERE
            (
                DAYS_SINCE_CREATION > ${max_object_age_without_tag}
                AND EXPIRY_DATE IS NULL
            ) OR (
                EXPIRY_DATE < CURRENT_DATE()
            )
    ;

    max_expiry_date DATE DEFAULT (SELECT DATEADD(day, ${max_expiry_days}, current_date())::DATE);

    run_id VARCHAR DEFAULT (SELECT UUID_STRING());

    drop_reason VARCHAR;
    log_record VARCHAR;
    sql_cmd VARCHAR;
    result VARCHAR DEFAULT '';
    rs RESULTSET;
BEGIN
    OPEN expired_objects;

    // Find all objects either >30 days old and not tagged, or where the expiry date tag as passed.
    // Drop these objects.
    FOR object IN expired_objects DO
        drop_reason := 'Expiry date for object has passed';
        IF (object.expiry_date IS NULL) THEN
            drop_reason := 'Object older than ${max_object_age_without_tag} days, with no expiry date tag.';
        END IF;

        sql_cmd := 'DROP ' || object.sql_object_type || ' "' || object.object_database || '"."' || object.object_schema || '".' || object.object_name || ';';

        IF (dry_run) THEN
            rs := (SELECT 'DRY_RUN');
        ELSE
            rs := (EXECUTE IMMEDIATE :sql_cmd);
        END IF;

        LET cur CURSOR FOR rs;
        OPEN cur;
        FETCH cur INTO RESULT;

        log_record := '{"sql":"' || REPLACE(sql_cmd,'"', '\\"') || '",
                        "action":"DROP_OBJECT",
                        "object_type":"' || object.object_type || '",
                        "reason_code":"EXPIRED_OBJECT",
                        "reason":"' || drop_reason || '",
                        "justification":{
                            "age":"' || object.days_since_creation || '",
                            "days_since_last_alteration":' || object.days_since_last_alteration || ',
                            "expiry_date":' || IFF(object.expiry_date IS NULL, 'null', '"' || object.expiry_date::varchar || '"') || '},
                        "result":' || IFF(result IS NULL, 'null', '"' || result || '"') || '}';

        INSERT INTO ${log_table_path} (event_time, run_id, record) SELECT CURRENT_TIMESTAMP(), :run_id, PARSE_JSON(:log_record);
    END FOR;

    // Find all tags > max allowed expiry_date, and set to max date
    let illegal_expiry_dates CURSOR FOR 
        SELECT
            object_database,
            object_schema,
            object_name,
            object_type,
            sql_object_type,
            expiry_date
        FROM
            ${object_ages_view_path}
        WHERE
            expiry_date > DATEADD(day, ${max_expiry_days}, current_date())::DATE
        ;

    OPEN illegal_expiry_dates;

    FOR object IN illegal_expiry_dates DO
        sql_cmd := 'ALTER ' || object.sql_object_type || ' "' || object.object_database || '"."' || object.object_schema || '".' || object.object_name || ' SET TAG ${expiry_date_tag_path} = "' || max_expiry_date::varchar || '";';

        IF (dry_run) THEN
            rs := (SELECT 'DRY_RUN');
        ELSE
            rs := (EXECUTE IMMEDIATE :sql_cmd);
        END IF;

        LET cur1 CURSOR FOR rs;
        OPEN cur1;
        FETCH cur1 INTO RESULT;

        log_record := '{"sql":"' || REPLACE(sql_cmd,'"', '\\"') || '",
                        "action":"ALTER_EXPIRY_DATE",
                        "object_type":"' || object.object_type || '",
                        "reason_code":"ILLEGAL_EXPIRY_DATE",
                        "reason":"Expiry tag is > ${max_expiry_days} days in the future.",
                        "justification":{
                            "expiry_date":' || IFF(object.expiry_date IS NULL, 'null', '"' || object.expiry_date::varchar || '"') || '},
                        "result":' || IFF(result IS NULL, 'null', '"' || result || '"') || '}';

        INSERT INTO ${log_table_path} (event_time, run_id, record) SELECT CURRENT_TIMESTAMP(), :run_id, PARSE_JSON(:log_record);

    END FOR;

    return 'Done. To view summary information, run: SELECT action, object_type, reason_code, result, count FROM ${log_summary_view_path} WHERE run_id = \''|| :run_id ||'\';';
EXCEPTION
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
END;
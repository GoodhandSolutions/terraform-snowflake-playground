SELECT
    event_time,
    run_id,
    record:sql::string AS sql_cmd,
    record:object_path::string AS object_path,
    record:object_type::string AS object_type,
    record:action::string AS action,
    record:status::string AS status,
    record:reason::string AS reason,
    record:justification:age::number AS object_age,
    record:justification:days_since_last_alteration::number AS days_since_last_object_alteration, --noqa: L016
    record:justification:expiry_date::date AS object_expiry_date,
    record:cmd_result::string AS cmd_result
FROM
    ${tbl_path}  --noqa
;

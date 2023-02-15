SELECT
    event_time,
    run_id,
    record:action::string AS action,
    record:object_type::string AS object_type,
    record:reason_code::string AS reason_code,
    record:reason::string AS reason,
    record:justification:age::number AS object_age,
    record:justification:days_since_last_alteration::number AS days_since_last_object_alteration,
    record:justification:expiry_date::date AS object_expiry_date,
    record:result::string AS result
FROM
    ${tbl_path}
;

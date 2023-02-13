SELECT
    run_id,
    action,
    object_type,
    reason_code,
    result,
    COUNT(*) AS count
FROM
    ${tbl_path}
GROUP BY
    1,2,3,4,5
;
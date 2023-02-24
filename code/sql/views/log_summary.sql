SELECT
    run_id,
    action,
    object_type,
    status,
    cmd_result,
    COUNT(*) AS count
FROM
    ${tbl_path}  --noqa
GROUP BY
    1, 2, 3, 4, 5;

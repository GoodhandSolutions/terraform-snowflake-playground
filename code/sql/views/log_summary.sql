SELECT
    MIN(t2.event_time) AS run_start_time,
    t1.run_id,
    t1.action,
    t1.object_type,
    t1.status,
    t1.cmd_result,
    COUNT(t1.*) AS count
FROM
    ${tbl_path} t1
INNER JOIN ${tbl_path} t2 ON t1.run_id = t2.run_id
GROUP BY
    2, 3, 4, 5, 6;

SELECT 
    object_database,
    object_schema,
    object_name,
    domain,
    TRY_TO_DATE(MAX(DECODE(tag_name, 'EXPIRY_DATE', tag_value, NULL))::varchar) AS expiry_date
FROM
    snowflake.account_usage.tag_references
WHERE tag_database = '${expiry_date_tag_database}'
    AND tag_schema = '${expiry_date_tag_schema}'
    AND object_deleted IS null
GROUP BY 1,2,3,4;
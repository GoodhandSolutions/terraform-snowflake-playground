DECLARE
    cs cursor for (
        SELECT
            object_database,
            object_schema,
            object_name,
            object_type,
            object_domain,
            days_since_creation,
            days_since_last_alteration,
            expiry_date,
            object_owner
        FROM
            ${snowflake_database.play.name}.${snowflake_schema.administration.name}.${snowflake_view.object_ages.name}
        WHERE
            (
                days_since_creation > ${var.max_object_age_without_tag}
                AND expiry_date IS NULL
            ) OR (
                expiry_date < CURRENT_DATE()
            )
        ORDER BY days_since_creation DESC
    );
BEGIN
    for record in cs do
        let drop_reason = 'Expiry date for object has passed';
        IF (record.expiry_date IS NULL) THEN
            drop_reason = 'Table older than ${var.max_object_age_without_tag} days, with no expiry date tag.';
        END IF;

        
        


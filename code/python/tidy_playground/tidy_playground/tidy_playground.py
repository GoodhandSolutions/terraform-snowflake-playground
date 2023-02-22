import datetime

def calc_max_date(days):
    return datetime.date.today()+ datetime.timedelta(days = days)

def read_expired_objects(session, object_ages_view_path, max_object_age_without_tag):
    return session.sql(f"""
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
        {object_ages_view_path}
      WHERE
        (
          DAYS_SINCE_CREATION > {max_object_age_without_tag}
          AND EXPIRY_DATE IS NULL
        ) OR (
          EXPIRY_DATE < CURRENT_DATE()
        )
    ;""")

def main(session, max_expiry_days, max_object_age_without_tag, object_ages_view_path):
    MAX_EXPIRY_DATE = calc_max_date(max_expiry_days)
    MAX_EXPIRY_TAG_DATE =calc_max_date(days=max_object_age_without_tag)

    expired_objects = read_expired_objects(session,
                                           object_ages_view_path,
                                           max_object_age_without_tag)

    return f"I ran a python command! Max expiry_date: {MAX_EXPIRY_DATE}, Max expiry tag date: {MAX_EXPIRY_TAG_DATE}."


# df_sql = session.sql("SELECT name from sample_product_data")
# df_table = session.table("sample_product_data")

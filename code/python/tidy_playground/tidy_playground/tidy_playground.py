import datetime
import json

def calc_max_date(days):
  return datetime.date.today()+ datetime.timedelta(days = days)

def get_illegal_objects(session,
                        object_ages_view_path,
                        max_object_age_without_tag,
                        max_expiry_tag_date):
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
      OBJECT_OWNER,
      CASE
        WHEN (DAYS_SINCE_CREATION > {max_object_age_without_tag}) AND (EXPIRY_DATE IS NULL) THEN 'EXPIRED_OBJECT'
        WHEN (EXPIRY_DATE < CURRENT_DATE()) THEN 'EXPIRED_TAG'
        WHEN (EXPIRY_DATE > {max_expiry_tag_date}) THEN 'ILLEGAL_TAG'
      END AS STATUS
    FROM
      {object_ages_view_path}
    WHERE
      (
        DAYS_SINCE_CREATION > {max_object_age_without_tag}
        AND EXPIRY_DATE IS NULL
      ) OR (
        EXPIRY_DATE < CURRENT_DATE()
      ) OR (
        EXPIRY_DATE > {max_expiry_tag_date}
      )
  ;""").collect()

def get_actions_from_status(object_details,
                            expiry_date_tag,
                            max_object_age_without_tag,
                            max_expiry_days,
                            max_expiry_tag_date):
  if object_details['STATUS'] == 'EXPIRED_OBJECT':
    reason = "Expiry date for object has passed"
    action = "DROP_OBJECT"
    sql = f"DROP {object_details['OBJECT_TYPE']} \"{object_details['OBJECT_DATABASE']}\".\"{object_details['OBJECT_SCHEMA']}\".\"{object_details['OBJECT_NAME']}\";"

    return {
      'reason': reason,
      'action': action,
      'sql': sql
    }
  elif object_details['STATUS'] == 'EXPIRED_TAG':
    reason = f"Object older than {max_object_age_without_tag} days without expiry tag."
    action = "DROP_OBJECT"
    sql = f"DROP {object_details['OBJECT_TYPE']} \"{object_details['OBJECT_DATABASE']}\".\"{object_details['OBJECT_SCHEMA']}\".\"{object_details['OBJECT_NAME']}\";"

    return {
      'reason': reason,
      'action': action,
      'sql': sql
    }
  elif object_details['STATUS'] == 'ILLEGAL_TAG':
    reason = f"Expiry tag date is more than {max_expiry_days} days from today."
    action = "ALTER_EXPIRY_DATE"
    sql = f"ALTER {object_details['OBJECT_TYPE']} \"{object_details['OBJECT_DATABASE']}\".\"{object_details['OBJECT_SCHEMA']}\".\"{object_details['OBJECT_NAME']}\" SET TAG {expiry_date_tag} = '{max_expiry_tag_date}';"

    return {
      'reason': reason,
      'action': action,
      'sql': sql
    }
  else:
    raise ValueError(f"Unknown status: {object_details['STATUS']}")

def main(session,
         dry_run,
         max_expiry_days,
         expiry_date_tag,
         max_object_age_without_tag,
         object_ages_view_path,
         log_table):
  MAX_EXPIRY_DATE = calc_max_date(max_expiry_days)
  MAX_EXPIRY_TAG_DATE = calc_max_date(days=max_object_age_without_tag)
  RUN_ID = session.sql('SELECT UUID_STRING()').collect().iloc[0,0]

  expired_objects = get_illegal_objects(session,
                                          object_ages_view_path,
                                          max_object_age_without_tag,
                                          MAX_EXPIRY_TAG_DATE)

  for _, row in expired_objects.iterrows():
    actions = get_actions_from_status(row['STATUS'],
                                      expiry_date_tag,
                                      max_object_age_without_tag,
                                      max_expiry_days,
                                      MAX_EXPIRY_TAG_DATE)

    if dry_run:
      result = 'DRY_RUN'
    else:
      result_df = session.sql(actions['sql']).collect()
      result = result_df.iloc[0,0]

    log_record = {
      'sql': actions['sql'],
      'action': actions['action'],
      'object_type': row['OBJECT_TYPE'],
      'reason_code': row['STATUS'],
      'reason': actions['sql'],
      'justification': {
        'age': row['DAYS_SINCE_CREATION'],
        'days_since_last_alteration': row['DAYS_SINCE_LAST_ALTERATION'],
        'expiry_date': row['EXPIRY_DATE']
      },
      'result': result
    }
    session.sql(f"""INSERT INTO {log_table} (event_time, run_id, record)
                      SELECT CURRENT_TIMESTAMP(),
                      '{RUN_ID}',
                      PARSE_JSON('{json.dumps(log_record)}')'
                ;""")

  return f"I ran a python command! Max expiry_date: {MAX_EXPIRY_DATE}, Max expiry tag date: {MAX_EXPIRY_TAG_DATE}."

# TODO: Catch permission denied errors.
# TODO: Have properties in a table, rather than passing in as arguments?

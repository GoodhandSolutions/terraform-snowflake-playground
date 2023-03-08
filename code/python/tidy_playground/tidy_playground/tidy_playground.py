import datetime
import json
import uuid
import pandas as pd

from snowflake.snowpark.exceptions import SnowparkSQLException


def get_illegal_objects(
    session, object_ages_view_path, max_object_age_without_tag, max_expiry_tag_date
):
    return session.sql(
        f"""
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
        WHEN (DAYS_SINCE_CREATION > {max_object_age_without_tag})
          AND (EXPIRY_DATE IS NULL) THEN 'EXPIRED_OBJECT'
        WHEN (EXPIRY_DATE < CURRENT_DATE()) THEN 'EXPIRED_TAG'
        WHEN (EXPIRY_DATE > '{max_expiry_tag_date}') THEN 'ILLEGAL_TAG'
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
        EXPIRY_DATE > '{max_expiry_tag_date}'
      )
    """
    ).collect()


def determine_actions_from_status(
    object_details,
    expiry_date_tag,
    max_object_age_without_tag,
    max_expiry_days,
    max_expiry_tag_date,
):
    """Determine the action to take for a given object.

    The 'STATUS' result for a given object is used to determine
    the action to take.

    Use this information to generate the SQL statement to execute,
    and the reason / action for the log.

    Args:
      - object_details: a row from the illegal_objects view
      - expiry_date_tag: the name of the expiry date tag
      - max_object_age_without_tag: the maximum age of an object without
        an expiry date tag
      - max_expiry_days: the maximum number of days in the future that
        an expiry date tag can be set
      - max_expiry_tag_date: the maximum date that an expiry date tag
        can be set

    Returns:
      - a dictionary containing the reason, action and SQL statement to
        take for the object
    """
    if object_details.STATUS == "EXPIRED_OBJECT":
        reason = "Expiry date for object has passed"
        action = "DROP_OBJECT"
        sql = (
            f"DROP {object_details.SQL_OBJECT_TYPE} "
            f'"{object_details.OBJECT_DATABASE}".'
            f'"{object_details.OBJECT_SCHEMA}".'
            f"{object_details.OBJECT_NAME}"
        )

        return {"reason": reason, "action": action, "sql": sql}
    elif object_details.STATUS == "EXPIRED_TAG":
        reason = (
            f"Object older than {max_object_age_without_tag} "
            f"days without expiry tag."
        )
        action = "DROP_OBJECT"
        sql = (
            f"DROP {object_details.SQL_OBJECT_TYPE} "
            f'"{object_details.OBJECT_DATABASE}".'
            f'"{object_details.OBJECT_SCHEMA}".'
            f"{object_details.OBJECT_NAME}"
        )

        return {"reason": reason, "action": action, "sql": sql}
    elif object_details.STATUS == "ILLEGAL_TAG":
        reason = (
            f"Expiry tag date is more than {max_expiry_days} " f"days in the future."
        )
        action = "ALTER_EXPIRY_DATE"
        sql = (
            f"ALTER {object_details.SQL_OBJECT_TYPE} "
            f'"{object_details.OBJECT_DATABASE}".'
            f'"{object_details.OBJECT_SCHEMA}".'
            f"{object_details.OBJECT_NAME} "
            f"SET TAG {expiry_date_tag} = '{max_expiry_tag_date}'"
        )

        return {"reason": reason, "action": action, "sql": sql}
    else:
        raise ValueError(f"Unknown status: {object_details.STATUS}")


def generate_log_record(row, actions, result):
    return {
        "sql": actions["sql"],
        "action": actions["action"],
        "object_type": row.OBJECT_TYPE,
        "status": row.STATUS,
        "reason": actions["reason"],
        "justification": {
            "age": row.DAYS_SINCE_CREATION,
            "days_since_last_alteration": row.DAYS_SINCE_LAST_ALTERATION,
            "expiry_date": row.EXPIRY_DATE.strftime("%Y-%m-%d")
            if (not pd.isnull(row.EXPIRY_DATE))
            else None,
        },
        "cmd_result": result,
    }


def main(
    session,
    is_dry_run,
    expiry_date_tag,
    max_expiry_days,
    max_object_age_without_tag,
    object_ages_view_path,
    log_table_path,
):
    """Tidy the Playground Environment of 'illegal' objects.

    Find all objects in the Playground environment that:
      - are older than max_object_age_without_tag days and have no
        expiry date tag
        - DROP
      - have an expiry date tag that is in the past
        - DROP
      - have an expiry date tag that is more than max_expiry_days in the future
        - ALTER Tag to be max_expiry_days in the future

    Args:
      - session: inserted snowpark session
      - is_dry_run: Whether the script should run in dry run mode.
      - expiry_date_tag: Path to the expiry date tag
      - max_expiry_days: Max number of days in the future that an expiry date
        tag can be set to
      - max_object_age_without_tag: Max number of days that an object can be
        without an expiry date tag
      - object_ages_view_path: Path to the view that contains the object ages
      - log_table: Path to the log table

    Returns:
      - string: result summary
    """
    EXPIRY_DATE_TAG = expiry_date_tag
    MAX_EXPIRY_DAYS = max_expiry_days
    MAX_OBJECT_AGE_WITHOUT_TAG = max_object_age_without_tag
    OBJECT_AGES_VIEW_PATH = object_ages_view_path
    LOG_TABLE_PATH = log_table_path
    MAX_EXPIRY_TAG_DATE = (
        datetime.date.today() + datetime.timedelta(days=MAX_EXPIRY_DAYS)
    ).strftime("%Y-%m-%d")

    RUN_ID = str(uuid.uuid4())

    illegal_objects = get_illegal_objects(
        session, OBJECT_AGES_VIEW_PATH, MAX_OBJECT_AGE_WITHOUT_TAG, MAX_EXPIRY_TAG_DATE
    )

    for row in illegal_objects:
        actions = determine_actions_from_status(
            row,
            EXPIRY_DATE_TAG,
            MAX_OBJECT_AGE_WITHOUT_TAG,
            MAX_EXPIRY_DAYS,
            MAX_EXPIRY_TAG_DATE,
        )

        if is_dry_run:
            cmd_result = "DRY_RUN"
        else:
            try:
                cmd_result = session.sql(actions["sql"]).collect()[0][0]
            except SnowparkSQLException as e:
                # SQL Access Control Error is code 1304.
                # We want to log this, but not fail the script,
                # so we can continue to handle other objects.
                if e.error_code == 1304:
                    cmd_result = "PERMISSION_DENIED"
                    pass
                else:
                    log_record = generate_log_record(row, actions, e.message)
                    log_record_json = (
                        json.dumps(log_record).replace("'", "\\'").replace('"', '\\"')
                    )
                    session.sql(
                        f"""INSERT INTO {LOG_TABLE_PATH}
                            (event_time, run_id, record)
                            SELECT CURRENT_TIMESTAMP(),
                            '{RUN_ID}',
                            PARSE_JSON('{log_record_json}')"""
                    ).collect()
                    raise

        log_record = generate_log_record(row, actions, cmd_result)

        # Need to escape single quotes and double-escape double quotes
        # so they are handled properly by Snowflake SQL.
        log_record_json = json.dumps(log_record).replace("'", "\\'").replace('"', '\\"')

        session.sql(
            f"""INSERT INTO {LOG_TABLE_PATH}
                (event_time, run_id, record)
                SELECT CURRENT_TIMESTAMP(),
                '{RUN_ID}',
                PARSE_JSON('{log_record_json}')"""
        ).collect()

    return "Success."

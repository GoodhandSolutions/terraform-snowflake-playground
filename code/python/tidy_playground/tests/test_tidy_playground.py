import pytest
import json
import pandas as pd

from tidy_playground.tidy_playground import determine_actions_from_status
from tidy_playground.tidy_playground import generate_log_record

MAX_EXPIRY_DAYS = 90
MAX_OBJECT_AGE_WITHOUT_TAG = 31


@pytest.fixture
def get_illegal_objects():
    df = pd.read_csv("./tests/illegal_objects.csv", quotechar="'")
    df["EXPIRY_DATE"] = pd.to_datetime(df["EXPIRY_DATE"], errors="ignore")
    return df


def test_actions_for_expired_object(snapshot, get_illegal_objects):
    actions = []
    log_records = []

    for _, row in get_illegal_objects.iterrows():
        if row['STATUS'] == 'SOME_OTHER_TAG':
            with pytest.raises(Exception):
                action = determine_actions_from_status(
                    row,
                    "PLAY.ADMINISTRATION.EXPIRY_DATE",
                    MAX_EXPIRY_DAYS,
                    MAX_OBJECT_AGE_WITHOUT_TAG,
                    "2023-05-23",
                )
        else:
            action = determine_actions_from_status(
                    row,
                    "PLAY.ADMINISTRATION.EXPIRY_DATE",
                    MAX_EXPIRY_DAYS,
                    MAX_OBJECT_AGE_WITHOUT_TAG,
                    "2023-05-23",
                )
            actions.append(action)
            log_records.append(json.dumps(generate_log_record(row, action, "DRY_RUN")))

    snapshot.assert_match(actions)
    snapshot.assert_match(log_records)

# -*- coding: utf-8 -*-
# snapshottest: v1 - https://goo.gl/zC4yUc
from __future__ import unicode_literals

from snapshottest import Snapshot


snapshots = Snapshot()

snapshots['test_actions_for_expired_object 1'] = [
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER EXTERNAL_NAMED "PLAY"."GROUND"."AWS_STAGE" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER PROCEDURE "PLAY"."GROUND"."SP_PI_MULTI_ARG"(FLOAT,VARCHAR) SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER BASE_TABLE "PLAY"."GROUND"."ANGIE_TBL" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER BASE_TABLE "PLAY"."GROUND"."MY_TBL" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER MATERIALIZED_VIEW "PLAY"."GROUND"."MY_MAT_VIEW" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'DROP_OBJECT',
        'reason': 'Object older than 30 days without expiry tag.',
        'sql': 'DROP PIPE "PLAY"."GROUND"."MY_PIPE";'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER PROCEDURE "PLAY"."GROUND"."MY_PROC"() SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'DROP_OBJECT',
        'reason': 'Object older than 30 days without expiry tag.',
        'sql': 'DROP VIEW "PLAY"."GROUND"."ANGIE_VIEW";'
    },
    {
        'action': 'DROP_OBJECT',
        'reason': 'Expiry date for object has passed',
        'sql': 'DROP BASE_TABLE "PLAY"."GROUND"."R2_TBL";'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER EXTERNAL_TABLE "PLAY"."GROUND"."MY_EXT_TBL" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'DROP_OBJECT',
        'reason': 'Expiry date for object has passed',
        'sql': 'DROP BASE_TABLE "PLAY"."GROUND"."PUBLIC";'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER BASE_TABLE "PLAY"."GROUND"."ANGIE_TEST_TBL" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER PROCEDURE "PLAY"."GROUND"."TEST_ERROR_HANDLE"() SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER INTERNAL_NAMED "PLAY"."GROUND"."MY_INT_STAGE" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER TASK "PLAY"."GROUND"."MY_TASK" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days from today.',
        'sql': 'ALTER STREAM "PLAY"."GROUND"."MY_STREAM" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';'
    }
]

snapshots['test_actions_for_expired_object 2'] = [
    '{"sql": "ALTER EXTERNAL_NAMED \\"PLAY\\".\\"GROUND\\".\\"AWS_STAGE\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "EXTERNAL_NAMED", "reason_code": "ILLEGAL_TAG", "reason": "ALTER EXTERNAL_NAMED \\"PLAY\\".\\"GROUND\\".\\"AWS_STAGE\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "ALTER PROCEDURE \\"PLAY\\".\\"GROUND\\".\\"SP_PI_MULTI_ARG\\"(FLOAT,VARCHAR) SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "PROCEDURE", "reason_code": "ILLEGAL_TAG", "reason": "ALTER PROCEDURE \\"PLAY\\".\\"GROUND\\".\\"SP_PI_MULTI_ARG\\"(FLOAT,VARCHAR) SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "ALTER BASE_TABLE \\"PLAY\\".\\"GROUND\\".\\"ANGIE_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "BASE_TABLE", "reason_code": "ILLEGAL_TAG", "reason": "ALTER BASE_TABLE \\"PLAY\\".\\"GROUND\\".\\"ANGIE_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "ALTER BASE_TABLE \\"PLAY\\".\\"GROUND\\".\\"MY_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "BASE_TABLE", "reason_code": "ILLEGAL_TAG", "reason": "ALTER BASE_TABLE \\"PLAY\\".\\"GROUND\\".\\"MY_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "ALTER MATERIALIZED_VIEW \\"PLAY\\".\\"GROUND\\".\\"MY_MAT_VIEW\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "MATERIALIZED_VIEW", "reason_code": "ILLEGAL_TAG", "reason": "ALTER MATERIALIZED_VIEW \\"PLAY\\".\\"GROUND\\".\\"MY_MAT_VIEW\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "DROP PIPE \\"PLAY\\".\\"GROUND\\".\\"MY_PIPE\\";", "action": "DROP_OBJECT", "object_type": "PIPE", "reason_code": "EXPIRED_TAG", "reason": "DROP PIPE \\"PLAY\\".\\"GROUND\\".\\"MY_PIPE\\";", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2022-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "ALTER PROCEDURE \\"PLAY\\".\\"GROUND\\".\\"MY_PROC\\"() SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "PROCEDURE", "reason_code": "ILLEGAL_TAG", "reason": "ALTER PROCEDURE \\"PLAY\\".\\"GROUND\\".\\"MY_PROC\\"() SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "DROP VIEW \\"PLAY\\".\\"GROUND\\".\\"ANGIE_VIEW\\";", "action": "DROP_OBJECT", "object_type": "VIEW", "reason_code": "EXPIRED_TAG", "reason": "DROP VIEW \\"PLAY\\".\\"GROUND\\".\\"ANGIE_VIEW\\";", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2022-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "DROP BASE_TABLE \\"PLAY\\".\\"GROUND\\".\\"R2_TBL\\";", "action": "DROP_OBJECT", "object_type": "BASE_TABLE", "reason_code": "EXPIRED_OBJECT", "reason": "DROP BASE_TABLE \\"PLAY\\".\\"GROUND\\".\\"R2_TBL\\";", "justification": {"age": 7, "days_since_last_alteration": 7.0, "expiry_date": NaN}, "result": "DRY_RUN"}',
    '{"sql": "ALTER EXTERNAL_TABLE \\"PLAY\\".\\"GROUND\\".\\"MY_EXT_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "EXTERNAL_TABLE", "reason_code": "ILLEGAL_TAG", "reason": "ALTER EXTERNAL_TABLE \\"PLAY\\".\\"GROUND\\".\\"MY_EXT_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "DROP BASE_TABLE \\"PLAY\\".\\"GROUND\\".\\"PUBLIC\\";", "action": "DROP_OBJECT", "object_type": "BASE_TABLE", "reason_code": "EXPIRED_OBJECT", "reason": "DROP BASE_TABLE \\"PLAY\\".\\"GROUND\\".\\"PUBLIC\\";", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": NaN}, "result": "DRY_RUN"}',
    '{"sql": "ALTER BASE_TABLE \\"PLAY\\".\\"GROUND\\".\\"ANGIE_TEST_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "BASE_TABLE", "reason_code": "ILLEGAL_TAG", "reason": "ALTER BASE_TABLE \\"PLAY\\".\\"GROUND\\".\\"ANGIE_TEST_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "ALTER PROCEDURE \\"PLAY\\".\\"GROUND\\".\\"TEST_ERROR_HANDLE\\"() SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "PROCEDURE", "reason_code": "ILLEGAL_TAG", "reason": "ALTER PROCEDURE \\"PLAY\\".\\"GROUND\\".\\"TEST_ERROR_HANDLE\\"() SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 1, "days_since_last_alteration": 1.0, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "ALTER INTERNAL_NAMED \\"PLAY\\".\\"GROUND\\".\\"MY_INT_STAGE\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "INTERNAL_NAMED", "reason_code": "ILLEGAL_TAG", "reason": "ALTER INTERNAL_NAMED \\"PLAY\\".\\"GROUND\\".\\"MY_INT_STAGE\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "ALTER TASK \\"PLAY\\".\\"GROUND\\".\\"MY_TASK\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "TASK", "reason_code": "ILLEGAL_TAG", "reason": "ALTER TASK \\"PLAY\\".\\"GROUND\\".\\"MY_TASK\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": NaN, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}',
    '{"sql": "ALTER STREAM \\"PLAY\\".\\"GROUND\\".\\"MY_STREAM\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "action": "ALTER_EXPIRY_DATE", "object_type": "STREAM", "reason_code": "ILLEGAL_TAG", "reason": "ALTER STREAM \\"PLAY\\".\\"GROUND\\".\\"MY_STREAM\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\';", "justification": {"age": 8, "days_since_last_alteration": NaN, "expiry_date": "2024-01-01"}, "result": "DRY_RUN"}'
]

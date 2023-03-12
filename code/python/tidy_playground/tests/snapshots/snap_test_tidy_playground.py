# -*- coding: utf-8 -*-
# snapshottest: v1 - https://goo.gl/zC4yUc
from __future__ import unicode_literals

from snapshottest import Snapshot


snapshots = Snapshot()

snapshots['test_actions_for_expired_object 1'] = [
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER PROCEDURE "PLAY"."GROUND"."SP_PI_MULTI_ARG"(FLOAT,VARCHAR) SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER TABLE "PLAY"."GROUND"."ANGIE_TBL" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER TABLE "PLAY"."GROUND"."MY_TBL" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER VIEW "PLAY"."GROUND"."MY_MAT_VIEW" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    },
    {
        'action': 'DROP_OBJECT',
        'reason': 'Object older than 31 days without expiry tag.',
        'sql': 'DROP PIPE "PLAY"."GROUND"."MY_PIPE"'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER PROCEDURE "PLAY"."GROUND"."MY_PROC"() SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    },
    {
        'action': 'DROP_OBJECT',
        'reason': 'Object older than 31 days without expiry tag.',
        'sql': 'DROP VIEW "PLAY"."GROUND"."ANGIE_VIEW"'
    },
    {
        'action': 'DROP_OBJECT',
        'reason': 'Expiry date for object has passed',
        'sql': 'DROP TABLE "PLAY"."GROUND"."R2_TBL"'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER TABLE "PLAY"."GROUND"."MY_EXT_TBL" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    },
    {
        'action': 'DROP_OBJECT',
        'reason': 'Expiry date for object has passed',
        'sql': 'DROP TABLE "PLAY"."GROUND"."PUBLIC"'
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER TABLE "PLAY"."GROUND"."ANGIE_TEST_TBL" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER PROCEDURE "PLAY"."GROUND"."TEST_ERROR_HANDLE"() SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER STAGE "PLAY"."GROUND"."MY_INT_STAGE" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER TASK "PLAY"."GROUND"."MY_TASK" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    },
    {
        'action': 'ALTER_EXPIRY_DATE',
        'reason': 'Expiry tag date is more than 90 days in the future.',
        'sql': 'ALTER STREAM "PLAY"."GROUND"."MY_STREAM" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\''
    }
]

snapshots['test_actions_for_expired_object 2'] = [
    '{"sql": "ALTER PROCEDURE \\"PLAY\\".\\"GROUND\\".\\"SP_PI_MULTI_ARG\\"(FLOAT,VARCHAR) SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"SP_PI_MULTI_ARG\\"(FLOAT,VARCHAR)", "object_type": "PROCEDURE", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "ALTER TABLE \\"PLAY\\".\\"GROUND\\".\\"ANGIE_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"ANGIE_TBL\\"", "object_type": "BASE_TABLE", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "ALTER TABLE \\"PLAY\\".\\"GROUND\\".\\"MY_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"MY_TBL\\"", "object_type": "BASE_TABLE", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "ALTER VIEW \\"PLAY\\".\\"GROUND\\".\\"MY_MAT_VIEW\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"MY_MAT_VIEW\\"", "object_type": "MATERIALIZED_VIEW", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "DROP PIPE \\"PLAY\\".\\"GROUND\\".\\"MY_PIPE\\"", "object_path": "PLAY.GROUND.\\"MY_PIPE\\"", "object_type": "PIPE", "action": "DROP_OBJECT", "status": "EXPIRED_TAG", "reason": "Object older than 31 days without expiry tag.", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2022-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "ALTER PROCEDURE \\"PLAY\\".\\"GROUND\\".\\"MY_PROC\\"() SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"MY_PROC\\"()", "object_type": "PROCEDURE", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "DROP VIEW \\"PLAY\\".\\"GROUND\\".\\"ANGIE_VIEW\\"", "object_path": "PLAY.GROUND.\\"ANGIE_VIEW\\"", "object_type": "VIEW", "action": "DROP_OBJECT", "status": "EXPIRED_TAG", "reason": "Object older than 31 days without expiry tag.", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2022-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "DROP TABLE \\"PLAY\\".\\"GROUND\\".\\"R2_TBL\\"", "object_path": "PLAY.GROUND.\\"R2_TBL\\"", "object_type": "BASE_TABLE", "action": "DROP_OBJECT", "status": "EXPIRED_OBJECT", "reason": "Expiry date for object has passed", "justification": {"age": 7, "days_since_last_alteration": 7.0, "expiry_date": null}, "cmd_result": "DRY_RUN"}',
    '{"sql": "ALTER TABLE \\"PLAY\\".\\"GROUND\\".\\"MY_EXT_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"MY_EXT_TBL\\"", "object_type": "EXTERNAL_TABLE", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "DROP TABLE \\"PLAY\\".\\"GROUND\\".\\"PUBLIC\\"", "object_path": "PLAY.GROUND.\\"PUBLIC\\"", "object_type": "BASE_TABLE", "action": "DROP_OBJECT", "status": "EXPIRED_OBJECT", "reason": "Expiry date for object has passed", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": null}, "cmd_result": "DRY_RUN"}',
    '{"sql": "ALTER TABLE \\"PLAY\\".\\"GROUND\\".\\"ANGIE_TEST_TBL\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"ANGIE_TEST_TBL\\"", "object_type": "BASE_TABLE", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "ALTER PROCEDURE \\"PLAY\\".\\"GROUND\\".\\"TEST_ERROR_HANDLE\\"() SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"TEST_ERROR_HANDLE\\"()", "object_type": "PROCEDURE", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 1, "days_since_last_alteration": 1.0, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "ALTER STAGE \\"PLAY\\".\\"GROUND\\".\\"MY_INT_STAGE\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"MY_INT_STAGE\\"", "object_type": "INTERNAL_NAMED", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 8, "days_since_last_alteration": 8.0, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "ALTER TASK \\"PLAY\\".\\"GROUND\\".\\"MY_TASK\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"MY_TASK\\"", "object_type": "TASK", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 8, "days_since_last_alteration": NaN, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}',
    '{"sql": "ALTER STREAM \\"PLAY\\".\\"GROUND\\".\\"MY_STREAM\\" SET TAG PLAY.ADMINISTRATION.EXPIRY_DATE = \'2023-05-23\'", "object_path": "PLAY.GROUND.\\"MY_STREAM\\"", "object_type": "STREAM", "action": "ALTER_EXPIRY_DATE", "status": "ILLEGAL_TAG", "reason": "Expiry tag date is more than 90 days in the future.", "justification": {"age": 8, "days_since_last_alteration": NaN, "expiry_date": "2024-01-01"}, "cmd_result": "DRY_RUN"}'
]

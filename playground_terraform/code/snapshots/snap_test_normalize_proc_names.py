# -*- coding: utf-8 -*-
# snapshottest: v1 - https://goo.gl/zC4yUc
from __future__ import unicode_literals

from snapshottest import Snapshot


snapshots = Snapshot()

snapshots['test_account_usage_source 1'] = '"TIDY_PLAYGROUND"(BOOLEAN)'

snapshots['test_info_schema_source 1'] = '"UPDATE_OBJECTS"(VARCHAR)'

snapshots['test_show_procs_source 1'] = '"UPDATE_OBJECTS"(VARCHAR)'

snapshots['test_simplify_argument_signature 1'] = 'NUMBER,STRING'

snapshots['test_tag_references_source 1'] = '"UPDATE_OBJECTS"(VARCHAR)'

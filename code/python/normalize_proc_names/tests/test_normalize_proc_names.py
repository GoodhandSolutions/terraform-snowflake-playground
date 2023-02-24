from normalize_proc_names import simplify_argument_signature, normalize_procedure_name


def test_simplify_argument_signature(snapshot):

    test_arg_sig = "(ACCOUNT_NUMBER NUMBER, ACCOUNT_NAME STRING)"

    returned_signature = simplify_argument_signature(test_arg_sig)
    snapshot.assert_match(returned_signature)


def test_info_schema_source(snapshot):
    normalized_name = normalize_procedure_name(
        "UPDATE_OBJECTS", "INFORMATION_SCHEMA", "(OBJECT_TYPE VARCHAR)"
    )
    snapshot.assert_match(normalized_name)


def test_account_usage_source(snapshot):
    normalized_name = normalize_procedure_name(
        "TIDY_PLAYGROUND", "ACCOUNT_USAGE", "(DRY_RUN BOOLEAN)"
    )
    snapshot.assert_match(normalized_name)


def test_show_procs_source(snapshot):
    normalized_name = normalize_procedure_name(
        "UPDATE_OBJECTS", "SHOW PROCEDURES", "UPDATE_OBJECTS(VARCHAR) RETURN VARCHAR"
    )
    snapshot.assert_match(normalized_name)


def test_tag_references_source(snapshot):
    normalized_name = normalize_procedure_name(
        "UPDATE_OBJECTS(OBJECT_TYPE VARCHAR):VARCHAR(16777216)", "TAG_REFERENCES"
    )
    snapshot.assert_match(normalized_name)

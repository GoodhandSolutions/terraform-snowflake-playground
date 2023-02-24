def simplify_argument_signature(arguments):
    """Simplifies the full argument definition of a function,
    to only the argument types.

    When Snowflake provides the arguments for a function, it often provides
    the name and type of each argument. However, when you need to reference
    the function for commands, you need the function, and then only the
    argument types, without the names.

    Args:
        arguments, string: containing the full arguments description,
        in the form:
            (arg1 arg1_type, arg2 arg2_type)

    Returns:
        string: simplified comma separated list of only the argument type of
        each argument, in the form:
            arg1_type, arg2_type
    """
    full_args = arguments.split('(')[1][0:-1]

    if len(full_args) < 1:
        return ''

    arg_types = []

    for arg in full_args.split(','):
        arg_types.append(arg.strip().split(' ')[1])

    return ','.join(arg_types)


def normalize_procedure_name(name, source, arguments=None):
    """Normalize the Snowflake procedure definitions into a uniform type
    useful for running new commands.

    Snowflake provides the name of a procedure in different forms, depending
    on where it is read from:
        - INFORMATION_SCHEMA and ACCOUNT_USAGE:
            `UPDATE_OBJECTS`, with `(OBJECT_TYPE VARCHAR)`,
            and `VARCHAR(16777216)` provided separately.
        - SHOW PROCEDURES:
            `UPDATE_OBJECTS` with `UPDATE_OBJECTS(VARCHAR) RETURN VARCHAR`
            provided separately
        - TAG_REFERENCES:
            `UPDATE_OBJECTS(OBJECT_TYPE VARCHAR):VARCHAR(16777216)`

    When calling procedure names as case-sensitive, the "" surround the proc
    name, but NOT the arguments. This means drop "my_proc"(), not drop
    "my_proc()". This is the form required for any SQL statements
    operating on the procedure.

    Args:
        name, string: The name of the procedure as provided by the source.
        source, string: Where the description (name / arguments) of the
            procedure have been sourced from.
        arguments, string (optional): The arguments of the procedure as
            provided by the source.

    Returns:
        string: normalized description of the procedure in the form:
            "UPDATE_OBJECTS"(VARCHAR)
    """
    if source in ['INFORMATION_SCHEMA', 'ACCOUNT_USAGE']:
        return f"\"{name}\"({simplify_argument_signature(arguments)})"
    elif source == 'SHOW PROCEDURES':
        name_without_return_type = arguments.split(' ')[0]
        simplified_argument_signature = name_without_return_type.split(
            '('
        )[1][:-1]

        return f"\"{name}\"({simplified_argument_signature})"
    elif source == 'TAG_REFERENCES':
        name_without_return_type = name.split(':')[0]
        raw_name = f"\"{name_without_return_type.split('(')[0]}\""

        return (
            f"{raw_name}"
            f"({simplify_argument_signature(name_without_return_type)})"
        )

    else:
        return None

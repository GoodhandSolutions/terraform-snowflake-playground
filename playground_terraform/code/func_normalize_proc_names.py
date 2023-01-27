def simplify_argument_signature(arguments):
    full_args = arguments.split('(')[1][0:-1]
    
    if len(full_args) < 1:
            return ''
    
    arg_types = []
    
    for arg in full_args.split(','):
            arg_types.append(arg.strip().split(' ')[1])
            
    return ','.join(arg_types)


def main(name, source, arguments):
    """Snowflake provides the name of a procedure in different forms,
    depending on where it is read from:
    It could be :
        - `UPDATE_OBJECTS`, with `(OBJECT_TYPE VARCHAR)`, and `VARCHAR(16777216)` provided separately (INFORMATION_SCHEMA and ACCOUNT_USAGE)
        - `UPDATE_OBJECTS` with `UPDATE_OBJECTS(VARCHAR) RETURN VARCHAR` provided separately (SHOW PROCEDURES)
        - `UPDATE_OBJECTS(OBJECT_TYPE VARCHAR):VARCHAR(16777216)` (TAG_REFERENCES)
    
    This function normalises all of these into the standard form:
        `"UPDATE_OBJECTS"(VARCHAR)`
    
    When calling procedure names as case-sensitive, the "" surround the proc name, but NOT the arguments:
    This means drop "my_proc"(), not drop "my_proc()"...
    
    Which is the form required for any SQL statements operating on the procedure.
    """
    if source in ['INFORMATION_SCHEMA', 'ACCOUNT_USAGE']:
        return f"\"{name}\"({simplify_argument_signature(arguments)})"
    elif source == 'SHOW PROCEDURES':
        name_without_return_type = arguments.split(' ')[0]
        simplified_argument_signature = name_without_return_type.split('(')[1][:-1]

        return f"\"{name}\"({simplified_argument_signature})"
    elif source == 'TAG_REFERENCES':
        name_without_return_type = name.split(':')[0]
        raw_name = f"\"{name_without_return_type.split('(')[0]}\""
        
        return f"{raw_name}({simplify_argument_signature(name_without_return_type)})"
    
    else:
        return None

# if __name__ == '__main__':
#     print(main('UPDATE_OBJECTS', 'SHOW PROCEDURES', 'UPDATE_OBJECTS(VARCHAR) RETURN VARCHAR'))
#     print(main('UPDATE_OBJECTS', 'INFORMATION_SCHEMA', '(OBJECT_TYPE VARCHAR)'))
#     print(main('UPDATE_OBJECTS(OBJECT_TYPE VARCHAR):VARCHAR(16777216)', 'TAG_REFERENCES', None))


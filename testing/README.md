# Integration Testing

This folder contains the infrastructure and testing code necessary to perform integration testing on the module in a Snowflake Account.

There are 3 parts, and they must be deployed / executed in order:

1. `test_deployment` - this is the deployment of the Snowflake Playground into the Snowflake Account
1. `test_objects` - these are a series of test objects that we can test executing `ALTER` and `DROP` SQL statements against
1. `tests` - the test scripts themselves

The [Makefile](./Makefile) contains the necessary commands to run the integration tests:

- `make test`
- `make clean` (to reset the testing environment)

**Important:** Because the Snowflake Playground relies on object tag values, and object ages, we have to load fake properties for the `OBJECT_AGES` view, this comes from the [object_ages.csv](./tests/data/object_ages.csv) file. These values are loaded into an alternative view `STATIC_OBJECT_AGES`.

# Snowflake Playground

Terraform module for creating a 'Playground' environment within a Snowflake account.

## Usage

```HCL
module "playground" {
    source  = "jagoodhand/playground/snowflake"
}
```

By default this will use your configured Snowflake provider to deploy a Playground into your Snowflake account with the configuration:

- Playground Schema: `PLAY.GROUND`
- Administration Schema: `PLAY.ADMINISTRATION`
- Expiry Date Tag: `PLAY.ADMINISTRATION.EXPIRY_DATE`
- Playground Warehouse: `PLAYGROUND_ADMIN_WAREHOUSE`
  - Size: `X-SMALL`
- TimeTravel for the Playground schema: `1 day`
- Standard max object age: `31`
- Max allowed expiry-date tag: `90 days in future`
- Automation schedule (disabled by default): `"USING CRON 0 3 * * * UTC"`

For safety, the playground automation is disabled by default. Set the following inputs to enable the playground:

```HCL
module "playground" {
    source  = "jagoodhand/playground/snowflake"

    dry_run = false
    tasks_enabled = true
}
```

## Object Types

  /*
  Includes:
  ext tables, materialized views, pipes, procedures, stages, streams, tables, tasks, views

  Excludes (because they cannot be tagged):
  tags, file formats, functions, masking policies, row access policies, sequences
  Excludes (because they don't exist outside of a session):
  temp tables

  You can't have views, materialized views, tables or ext tables with the same name.
  These objects can therefore all be treated as tables.
  */

## Security / Permissions


## Automation Logic


## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/jagoodhand/terraform-snowflake-playground/issues/new) section.

Full contributing [guidelines are covered here](.github/contributing.md).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/jagoodhand/terraform-snowflake-playground/blob/main/LICENSE) for full details.

## Authors

Module is maintained by [James Goodhand](https://github.com/jagoodhand).

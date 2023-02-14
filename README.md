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

For safety, the playground automation is disabled by default. Set the following inputs to enable the automation:

```HCL
module "playground" {
    source  = "jagoodhand/playground/snowflake"

    dry_run = false
    tasks_enabled = true
}
```

## Playground Logic



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


## Contributing

Report issues/questions/feature requests on in the [issues](https://github.com/jagoodhand/terraform-snowflake-playground/issues/new) section.

Full contributing [guidelines are covered here](.github/contributing.md).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/jagoodhand/terraform-snowflake-playground/blob/main/LICENSE) for full details.

## Authors

Module is maintained by [James Goodhand](https://github.com/jagoodhand).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.7 |
| <a name="requirement_snowflake"></a> [snowflake](#requirement\_snowflake) | 0.54.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_snowflake"></a> [snowflake](#provider\_snowflake) | 0.54.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [snowflake_database.play](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/database) | resource |
| [snowflake_database_grant.play_usage](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/database_grant) | resource |
| [snowflake_function.normalize_proc_names](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/function) | resource |
| [snowflake_object_parameter.log_table_data_retention](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/object_parameter) | resource |
| [snowflake_procedure.tidy_playground](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/procedure) | resource |
| [snowflake_procedure.update_objects](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/procedure) | resource |
| [snowflake_schema.administration](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema) | resource |
| [snowflake_schema.ground](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema) | resource |
| [snowflake_schema_grant.play_administration_grant_usage](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_external_table](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_file_format](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_function](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_masking_policy](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_materialized_view](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_pipe](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_procedure](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_row_policy](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_sequence](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_stage](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_stream](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_table](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_task](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_temporary_table](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_usage](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_schema_grant.play_ground_grant_view](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/schema_grant) | resource |
| [snowflake_table.log_table](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/table) | resource |
| [snowflake_table.streams](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/table) | resource |
| [snowflake_table.tasks](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/table) | resource |
| [snowflake_tag.expiry_date_tag](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/tag) | resource |
| [snowflake_tag_grant.expiry_date_apply_grant](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/tag_grant) | resource |
| [snowflake_task.tidy](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/task) | resource |
| [snowflake_task.update_stream_objects](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/task) | resource |
| [snowflake_task.update_task_objects](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/task) | resource |
| [snowflake_view.log_summary](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/view) | resource |
| [snowflake_view.log_view](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/view) | resource |
| [snowflake_view.object_ages](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/view) | resource |
| [snowflake_view.object_tags](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/view) | resource |
| [snowflake_view_grant.select_object_ages_grant](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/view_grant) | resource |
| [snowflake_view_grant.select_object_tags_grant](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/view_grant) | resource |
| [snowflake_warehouse.playground_admin_warehouse](https://registry.terraform.io/providers/Snowflake-Labs/snowflake/0.54.0/docs/resources/warehouse) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_retention_time"></a> [data\_retention\_time](#input\_data\_retention\_time) | Snowflake Data Retention value for the Playground Schema. | `number` | `1` | no |
| <a name="input_dry_run"></a> [dry\_run](#input\_dry\_run) | Whether the playground tidying procedure should alter tags / drop objects, or just log its planned actions. | `bool` | `true` | no |
| <a name="input_expiry_date_tag_database"></a> [expiry\_date\_tag\_database](#input\_expiry\_date\_tag\_database) | Database where the expiry date tag utilised for the playground should be created. | `string` | `"PLAY"` | no |
| <a name="input_expiry_date_tag_name"></a> [expiry\_date\_tag\_name](#input\_expiry\_date\_tag\_name) | Name for the expiry date tag. | `string` | `"EXPIRY_DATE"` | no |
| <a name="input_expiry_date_tag_schema"></a> [expiry\_date\_tag\_schema](#input\_expiry\_date\_tag\_schema) | Schema where the expiry date tag utilitsed for the playground should be created. | `string` | `"ADMINISTRATION"` | no |
| <a name="input_max_expiry_days"></a> [max\_expiry\_days](#input\_max\_expiry\_days) | Max number of days that an expiry date tag can be set in the future. If a tag is set beyond this value, then it will be reduced to the date defined by this number of days in the future. | `number` | `90` | no |
| <a name="input_max_object_age_without_tag"></a> [max\_object\_age\_without\_tag](#input\_max\_object\_age\_without\_tag) | Max number of days to allow an object to exist in the playground without an expiry date before it is dropped. | `number` | `31` | no |
| <a name="input_playground_admin_schema_name"></a> [playground\_admin\_schema\_name](#input\_playground\_admin\_schema\_name) | Name of the administrative schema within the Playground Database where the supporting objects for the playground will be created. | `string` | `"ADMINISTRATION"` | no |
| <a name="input_playground_db_name"></a> [playground\_db\_name](#input\_playground\_db\_name) | Name of the database that should be created to house the Playground environment. Must not be an existing database name. | `string` | `"PLAY"` | no |
| <a name="input_playground_schema_name"></a> [playground\_schema\_name](#input\_playground\_schema\_name) | Name of the schema within the Playground Database where the Playground environment will exist. | `string` | `"GROUND"` | no |
| <a name="input_playground_warehouse_name"></a> [playground\_warehouse\_name](#input\_playground\_warehouse\_name) | Name of the warehouse that will be used to perform Playground activities. A new warehouse will be created to manage the playground activities. | `string` | `"playground_admin_warehouse"` | no |
| <a name="input_playground_warehouse_size"></a> [playground\_warehouse\_size](#input\_playground\_warehouse\_size) | Size of the warehouse that will be used to support the Playground activities. XS should be apprioriate unless you have a particularly large account. In this case, you can look at the query times of the warehouse, and experiment with increasing the warehouse size. | `string` | `"xsmall"` | no |
| <a name="input_task_cron_schedule"></a> [task\_cron\_schedule](#input\_task\_cron\_schedule) | CRON schedule on which the playground tidying tasks should be executed. | `string` | `"USING CRON 0 3 * * * UTC"` | no |
| <a name="input_tasks_enabled"></a> [tasks\_enabled](#input\_tasks\_enabled) | Whether the playground tidying tasks are enabled or not. | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

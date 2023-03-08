# src

This [main.tf](./main.tf) illustrates how to call this Terraform module from the source code, rather than replying on a download of the module from the Terraform Website:

```HCL
module "playground" {
  source = "../.." #"jagoodhand/playground/snowflake"

  tasks_enabled = true
  dry_run       = false

  playground = {
    database              = "PLAY"
    schema                = "GROUND"
    is_transient          = false
    administration_schema = "ADMINISTRATION"
  }
}
```

# Change Playground Parameters

This example is similar to the [basic](../basic/) example, but illustrates how to override some of the Playground Configuration Defaults:

```HCL
  playground = {
    database              = "PLAY"
    schema                = "GROUND"
    is_transient          = false
    administration_schema = "ADMINISTRATION"
  }
```

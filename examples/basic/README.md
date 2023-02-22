# Basic Example

The [main.tf](./main.tf) file shows the most-basic configuration needed to deploy the Snowflake Playground to your Snowflake environment.

You just need to provide your Snowflake variables. The easiest way to do this is via Environment Variables:

```zsh
export TF_VAR_snowflake_user="MY_SNOWFLAKE_USER"
export TF_VAR_snowflake_account="my_snowflake_account_identifier"
export TF_VAR_snowflake_rsa_key_path="/my/rsa/key/path.p8"
```

Here authentication with your Snowflake user is done using RSA Key authentication. Instructions on how to setup RSA Key Authentication can be found in the [Snowflake Documentation](https://docs.snowflake.com/en/user-guide/key-pair-auth#configuring-key-pair-authentication).

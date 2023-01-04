###############################################################
# Playground Database
###############################################################
resource "snowflake_database" "play" {
    name = var.playground_db_name
    data_retention_time_in_days = var.data_retention_time
}

resource "snowflake_database_grant" "play_usage" {
    depends_on = [
      snowflake_database.play
    ]

    database_name = "${snowflake_database.play.name}"

    privilege = "USAGE"
    roles = ["PUBLIC"]

    with_grant_option = false
}
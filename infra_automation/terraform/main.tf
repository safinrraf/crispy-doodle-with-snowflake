# Specify required providers
terraform {
  required_providers {
    snowflake = {
      source = "Snowflake-Labs/snowflake"
    }
  }
}

# Snowflake provider configuration
provider "snowflake" {
  role                   = "terraform_role"
  private_key_passphrase = "123"
}

# Create a new Snowflake database
resource "snowflake_database" "util_db" {
  name         = "UTIL_DB"
  is_transient = false
  comment      = "Database for the ESS-DNGW Badge 5: Data Engineering Workshop"
}

resource "snowflake_database_role" "db_role" {
  database = snowflake_database.util_db.name
  name     = "util_db_role"
}

# all privileges + grant option + always apply
resource "snowflake_grant_privileges_to_database_role" "example" {
  database_role_name = snowflake_database_role.db_role.fully_qualified_name
  on_database        = snowflake_database_role.db_role.database
  always_apply       = true
  all_privileges     = true
  with_grant_option  = true
}

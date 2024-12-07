#!/bin/bash

# Example command to derive the SNOWFLAKE_ACCOUNT value (placeholder, requires actual execution in context)
# SNOWFLAKE_ACCOUNT=$(SELECT LOWER(current_organization_name() || '-' || current_account_name()) as YOUR_SNOWFLAKE_ACCOUNT)

# Set environment variables
export SNOWFLAKE_USER="terraform_user"
export SNOWFLAKE_AUTHENTICATOR="JWT"

# Correctly substitute the content of the private key file into the variable
if SNOWFLAKE_PRIVATE_KEY=$(cat ~/.ssh/rsa_key_snowflake_fgulwhl_oz51801_terraform_user.p8 2>/dev/null); then
    export SNOWFLAKE_PRIVATE_KEY
else
    printf "Error: Unable to read the private key file.\n" >&2
    exit 1
fi

export SNOWFLAKE_ACCOUNT="fgulwhl-oz51801"

printf "Environment variables have been set successfully:\n"
env | grep 'SNOWFLAKE_'

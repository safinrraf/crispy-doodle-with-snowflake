SELECT
    LOWER(
        current_organization_name () || '-' || current_account_name ()
    ) as YOUR_SNOWFLAKE_ACCOUNT;

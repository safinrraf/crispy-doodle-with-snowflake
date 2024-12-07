use role accountadmin;

create
or replace external function util_db.public.grader (
    step varchar,
    passed boolean,
    actual integer,
    expected integer,
    description varchar
) returns variant api_integration = dora_api_integration context_headers = (
    current_timestamp,
    current_account,
    current_statement,
    current_account_name
) as 'https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora/grader';

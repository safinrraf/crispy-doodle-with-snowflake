use role accountadmin;

create
or replace api integration dora_api_integration api_provider = aws_api_gateway api_aws_role_arn = 'arn:aws:iam::321463406630:role/snowflakeLearnerAssumedRole' enabled = true api_allowed_prefixes = (
    'https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora'
);

show integrations;

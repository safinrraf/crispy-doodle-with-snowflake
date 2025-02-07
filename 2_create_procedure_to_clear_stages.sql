CREATE OR REPLACE TABLE deleted_files_log (
    schema_name STRING,
    table_name STRING,
    file_name STRING,
    deletion_timestamp TIMESTAMP
);

--NOT FINISHED AND NOT TESTED

CREATE OR REPLACE PROCEDURE remove_staged_files()
RETURNS STRING
LANGUAGE SQL 
AS 
DECLARE 
    sql_cmd STRING;
    list_cmd STRING;
    table_name STRING;
    schema_name STRING;
    staged_file STRING;
    rs RESULTSET;
BEGIN
    LET cr CURSOR FOR SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
    -- Loop through all tables in the database
    FOR table_rec IN cr 
    DO
        schema_name := table_rec.TABLE_SCHEMA;
        table_name := table_rec.TABLE_NAME;

        -- Construct LIST command to get staged files
        list_cmd := 'LIST @%' || schema_name || '.' || table_name;
        rs := (EXECUTE IMMEDIATE :list_cmd);
        
        -- Iterate over the staged files
        FOR file_rec IN rs
        DO
            staged_file := file_rec.name;

            -- Log the file before deletion
            INSERT INTO deleted_files_log 
            VALUES (schema_name, table_name, staged_file, CURRENT_TIMESTAMP);
        END FOR;

        -- Remove all files from the table stage
        sql_cmd := 'REMOVE @%' || schema_name || '.' || table_name;
        EXECUTE IMMEDIATE :sql_cmd;
    END FOR;
    
    RETURN 'All table stages cleared successfully, deleted files logged in deleted_files_log table';
END;


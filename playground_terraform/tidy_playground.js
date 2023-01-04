// -- SETTINGS
var db_name = "SCRATCH";

// -- Temp variables
var result = "";
var sql = "";
var sqlResult = "";

// TODO: Update to include all object types.

try {
    // -- Find all tables that are either: > 30 days old and not tagged, OR where the expiry tag date has passed - drop
    sql = "select TABLE_DATABASE, TABLE_SCHEMA, TABLE_NAME, DAYS_SINCE_CREATION, DAYS_SINCE_LAST_ALTERATION, TRY_TO_DATE(EXPIRY_DATE) as EXPIRY_DATE, TABLE_OWNER, TABLE_TYPE from scratch.administration.table_ages " +
          "where (DAYS_SINCE_CREATION > 30 " +
          "and EXPIRY_DATE is null) " +
          "or (EXPIRY_DATE < CURRENT_DATE()) " +
          "order by DAYS_SINCE_CREATION desc;"
    rs = snowflake.execute({sqlText: sql});
    while (rs.next())  {
        var tbl_type = "TABLE";
        
        if (rs.getColumnValue(8) != "BASE TABLE") {
            tbl_type = rs.getColumnValue(8);
        }

        var reason = "Expiry date for object has passed.";
        if (rs.getColumnValue(6) == null) {
            reason = "Table older than 30 days, with no expiry date tag.";
        }
        
        // -- Need to use ' rather than " here, because the DROP command needs to use a case sensitive name (provided in "") to ensure that the drop succeeds.
        var sqlCmd = 'DROP ' + tbl_type + ' "' + db_name + '"."WORKSPACE"."' + rs.getColumnValue(3) + '";';
        var tmpResult = snowflake.execute({sqlText: sqlCmd});
        tmpResult.next()
        var json = '{"sql":"' + sqlCmd.replace(/["']/g, '\\"') + '","action":"DROP_TABLE","target_name":"' + rs.getColumnValue(3) + '","target_type":"' + rs.getColumnValue(8) + '","reason":"' + reason + '","justification":{"date_created":"' + rs.getColumnValue(4) + '","days_since_last_altered":"' + rs.getColumnValue(5) + '","expiry_date_tag":"' + rs.getColumnValue(6) + '"},"result":"' + tmpResult.getColumnValue(1) + '"}'; 
        snowflake.createStatement( { sqlText: `insert into scratch.administration.log (event_time, record) select current_timestamp(), parse_json(:1);`, binds:[json] } ).execute();        
    }
    
    // -- Get date 90 days in advanced
    sql = "SELECT DATEADD(day, 90, current_date())::TIMESTAMP_LTZ::DATE;";
    rs = snowflake.execute({sqlText: sql});
    rs.next()
    var sfdate = rs.getColumnValue(1);
    var date_plus_90 = sfdate.toISOString().split("T")[0];
    
    // -- Find all tags > 90 days in advanced and set to 90 days
    sql = "SELET table_database, table_schema, table_name, table_type, TRY_TO_DATE(EXPIRY_DATE) AS EXPIRY_DATE FROM scratch.administration.table_ages " +
          "WHERE DATEDIFF(days, CURRENT_DATE(), expiry_date) > 90;";
    rs = snowflake.execute({sqlText: sql});
    
    while (rs.next()) {
        var tbl_type = "TABLE";
        
        if (rs.getColumnValue(4) != "BASE TABLE") {
            tbl_type = rs.getColumnValue(4);
        }
        
        var sqlCmd = 'ALTER ' + tbl_type + ' "' + db_name + '"."WORKSPACE"."' + rs.getColumnValue(3) + '" set tag ACCOUNT_OBJECTS.TAGS.EXPIRY_DATE = "' + date_plus_90 + '";';
        var tmpResult = snowflake.execute({sqlText: sqlCmd});
        tmpResult.next()
        var json = '{"sql":"' + sqlCmd.replace(/["']/g, '\\"') + '","action":"ALTER_TABLE_EXPIRY","target_name":"' + rs.getColumnValue(3) + '","target_type":"' + rs.getColumnValue(4) + '","reason":"Expiry tag is > 90 days in the future.","justification":{"expiry_date_tag":"' + rs.getColumnValue(5) + '"},"result":"' + tmpResult.getColumnValue(1) + '"}'; 
        snowflake.createStatement( { sqlText: `insert into scratch.administration.log (event_time, record) select current_timestamp(), parse_json(:1);`, binds:[json] } ).execute();        
    }
    
    return "Done";
} catch (err) {
    result += "\nMessage    :\n" + err.message + "\n";
    result += "\nLast SQL   :\n" + sql + "\n";
    result += "\nStack Trace:\n" + err.stackTraceTxt;  
    throw result;
}
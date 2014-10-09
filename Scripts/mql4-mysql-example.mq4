//+------------------------------------------------------------------+
//|                                           mql4-mysql-example.mq4 |
//|                                                                  |
//|                                                     Sergey Lukin |
//|                                          contact@sergeylukin.com |
//+------------------------------------------------------------------+
#property copyright "Unlicense"
#property link      "http://unlicense.org/"

#include <mql4-mysql.mqh>

string  host     = "localhost";
string  user     = "root";
string  pass     = "123456";
string  dbName   = "information_schema";

int     port     = 3306;
int     socket   = 0;
int     client   = 0;

int     dbConnectId = 0;
bool    goodConnect = false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start () {
    goodConnect = init_MySQL(dbConnectId, host, user, pass, dbName, port, socket, client);
    
    if ( !goodConnect ) {
        return (1); // bad connect
    }

    //+-------------------------------------------------------------------
    //| Fetch multiple columns in multiple rows
    //+-------------------------------------------------------------------    
    string query = StringConcatenate(
        "SELECT `TABLE_NAME`, `TABLE_ROWS`, `CREATE_TIME`, `CHECK_TIME` ",
            "FROM `TABLES` ",
            "WHERE `TABLE_SCHEMA` = \'mysql\'");
    string data[][4];   // important: second dimension size must be equal to the number of columns
    int result = MySQL_FetchArray(dbConnectId, query, data);
    
    if ( result == 0 ) {
        // Print("0 rows selected");
    } else if ( result == -1 ) {
        // Print("some error occured");
    } else {
        // Print("Query was successful. Printing rows...");
        int num_rows = ArrayRange(data, 0);
        int num_fields = ArrayRange(data, 1);
        
        for ( int i = 0; i < num_rows; i++) {
            string line = "";
            
            for ( int j = 0; j < num_fields; j++ ) {
               string value = data[i][j];
                line = StringConcatenate(line, value, ";");
            }
            Print(line);
        }
    }
    
    //+-------------------------------------------------------------------
    //| Single row fetch
    //| Similar to array fetch
    //+-------------------------------------------------------------------
    string row[][4];   // important: second dimension size must be equal to the number of columns
    string rowQuery = StringConcatenate("SELECT `TABLE_NAME`, `TABLE_ROWS`, `CREATE_TIME`, `CHECK_TIME` ",
            "FROM `TABLES` ",
            "WHERE `TABLE_SCHEMA` = \'mysql\' ",
            "LIMIT 0,1");
    int row_result = MySQL_FetchArray(dbConnectId, rowQuery, row);
    line = "One row query: ";
    for(int r=0; r < ArrayRange(row, 1); r++) {
      line = StringConcatenate(line, row[0][r], ";");
    }
    Print(line);
    
    //+-------------------------------------------------------------------
    //| Sample INSERT
    //| It's just an example, nobody can insert into information_schema.
    //+-------------------------------------------------------------------
    /*string insertQuery  = StringConcatenate(
        "INSERT INTO `CHARACTER_SETS` VALUES (", "sometext"
                                        , "," , "oneMoreText"
                                        , "," , "andVarialbe"
                                        , "," , "nextWillBeNumber"
                                        , "," , 2
                                        , ")"
        );
    if ( MySQL_Query(dbConnectId, insertQuery) ) {
        Print("insert good");
    }*/
    
    
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return (0);
}
//+------------------------------------------------------------------+
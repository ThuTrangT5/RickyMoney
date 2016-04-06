//
//  RMDataManagement.m
//  RickyMoney
//
//  Created by Thu Trang on 4/6/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMDataManagement.h"
#import <sqlite3.h>

#define DATABASE_FILE_NAME @"RM-DATABASE.DB"


static RMDataManagement *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation RMDataManagement {
    NSString *databasePath;
}

+ (RMDataManagement*) getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

- (BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: DATABASE_FILE_NAME]];
    
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            // create tables
            [self createTables:@"USER"
                  tableColumns: [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"text", @"email",
                                 @"text", @"password",
                                 @"text", @"currencyId",
                                 @"blob", @"avatar",
                                 nil]];
            
            
            [self createTables:@"CURRENCY"
                  tableColumns: [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"text", @"name",
                                 @"text", @"symbol",
                                 @"blob", @"image",
                                 nil]];
            
            
            [self createTables:@"CATEGORY"
                  tableColumns: [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"text", @"enName",
                                 @"text", @"vnName",
                                 @"blob", @"icon",
                                 nil]];
            
            
            [self createTables:@"RMTRANSACTION"
                  tableColumns: [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"text", @"item",
                                 @"real", @"amount",
                                 @"integer", @"type",
                                 @"text", @"userId",
                                 @"text", @"categoryId",
                                 @"text", @"date", // format : YYYY-MM-DD
                                 @"text", @"notes",
                                 nil]];
            
            
            sqlite3_close(database);
            
        } else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

- (void) createTables:(NSString*) tableName tableColumns:(NSDictionary*) columns {
    
    NSString *sqlString = @"";
    for (NSString *key in columns.allKeys) {
        NSString *columnName = key;
        NSString *columnType = [columns valueForKey:key];
        sqlString = [NSString stringWithFormat:@"%@, %@ %@", sqlString, columnName, columnType];
    }
    
    sqlString = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (objectId text primary key %@)", tableName, sqlString];
    
    char *errMsg;
    const char *sql_stmt = [sqlString UTF8String];
    
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
        NSLog(@"Failed to create table: %s", errMsg);
    }
}

- (void) insertIntoTable:(NSString*) tableName values:(NSDictionary*) values {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *autoId = [formatter stringFromDate:[NSDate new]];
        autoId = [NSString stringWithFormat:@"RM_%@_%@", [tableName substringToIndex:1], autoId];
        
        NSString *columnNames = @"";
        NSString *columnValues = @"";
        for (NSString *key in values.allKeys) {
            columnNames = [NSString stringWithFormat:@"%@, %@", columnNames, key];
            columnValues = [NSString stringWithFormat:@"%@, \"%@\"", columnValues, [values valueForKey: key]];
        }
        NSString *insertSQL = [NSString stringWithFormat: @"INSERT INTO %@ (objectId%@) VALUES (\"%@\"%@)", tableName, columnNames, autoId, columnValues];
        const char *insert_stmt = [insertSQL UTF8String];
        
//        if(sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL) != SQLITE_OK) {
//            NSLog(@"Error while creating INSERT statement. '%s'", sqlite3_errmsg(database));
//        }
//        if (sqlite3_step(statement) == SQLITE_DONE) {
//            NSLog(@"SUCCESS: %@", insertSQL);
//        } else {
//            NSLog(@"error");
//        }
//        sqlite3_finalize(statement);
        
        char * errMsg;
        int result = sqlite3_exec(database, insert_stmt, NULL, NULL, &errMsg);
        if(result != SQLITE_OK) {
            NSLog(@"Failed to insert record  rc:%d, msg=%s",result,errMsg);
        }

        sqlite3_close(database);
    }
}


@end

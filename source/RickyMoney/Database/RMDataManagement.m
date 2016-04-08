//
//  RMDataManagement.m
//  RickyMoney
//
//  Created by Thu Trang on 4/6/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMDataManagement.h"
#import "DatabaseVariables.h"
#import <sqlite3.h>


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
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        [self createUserTable];
        [self createCurrencyTable];
        [self createCategoryTable];
        [self createTransactionTable];
        [self createBudgetTable];
    }
    return isSuccess;
}

- (void) createUserTable {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *createQuery = [NSString stringWithFormat: CREATE_USER_TABLE_QUERY, USER_TABLE_NAME];
        char * errMsg;
        if (sqlite3_exec(database, [createQuery UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Failed to create USER table: %s", errMsg);
        }
        sqlite3_close(database);
    }
}

- (void) createCurrencyTable {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *createQuery = [NSString stringWithFormat:CREATE_CURRENCY_TABLE_QUERY, CURRENCY_TABLE_NAME];
        char * errMsg;
        if (sqlite3_exec(database, [createQuery UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Failed to create CURRENCY table: %s", errMsg);
        }
        sqlite3_close(database);
    }
}

- (void) createCategoryTable {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *createQuery = [NSString stringWithFormat:CREATE_CATEGORY_TABLE_QUERY, CATEGORY_TABLE_NAME];
        char * errMsg;
        if (sqlite3_exec(database, [createQuery UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Failed to create CATEGORY table: %s", errMsg);
        }
        sqlite3_close(database);
    }
}

- (void) createTransactionTable {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *createQuery = [NSString stringWithFormat:CREATE_TRANSACTION_TABLE_QUERY, TRANSACTION_TABLE_NAME];
        char * errMsg;
        if (sqlite3_exec(database, [createQuery UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Failed to create TRANSACTION table: %s", errMsg);
        }
        sqlite3_close(database);
    }
}

- (void) createBudgetTable {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *createQuery = [NSString stringWithFormat:CREATE_BUDGET_TABLE_QUERY, BUDGET_TABLE_NAME];
        char * errMsg;
        if (sqlite3_exec(database, [createQuery UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Failed to create BUDGET table: %s", errMsg);
        }
        sqlite3_close(database);
    }
}

#pragma mark- REPARE DATA

- (NSString*) createAutoIdentifierForTable:(NSString*) tableName {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *autoId = [formatter stringFromDate:[NSDate new]];
    autoId = [NSString stringWithFormat:@"RM_%@_%@", [tableName substringToIndex:1], autoId];
    
    return autoId;
}


#pragma mark- USER

- (NSString*) createNewUserWithEmail:(NSString *) email password:(NSString*) password {
    NSString *createdUserId = nil; // result is the created user id
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSString *userId = [self createAutoIdentifierForTable: USER_TABLE_NAME];
        NSString *insertQuery = [NSString stringWithFormat:@"insert into %@ (objectId, email, password, currencyId) values (%@, %@, %@, RMCurreny_01_VND)", USER_TABLE_NAME, userId, email, password];
        
        char * errMsg;
        int result = sqlite3_exec(database, [insertQuery UTF8String], NULL, NULL, &errMsg);
        if(result != SQLITE_OK) {
            NSLog(@"Failed to insert record  rc:%d, msg=%s",result,errMsg);
        } else {
            NSLog(@"Insert new User(%@, %@) successfully", userId, email);
            createdUserId = userId;
        }
        
        sqlite3_close(database);
    }
    
    return createdUserId;
}
- (NSString*) loginWithEmail:(NSString*) email andPassword:(NSString*) password {
 
    return nil;
}

- (BOOL) updateCurrency:(NSString*) currencyId forUser:(NSString *) userId {
    
    return NO;
    
}
- (BOOL) updateAvatar:(UIImage*) avatar forUser:(NSString*) userId {
    
    return NO;
}
- (BOOL) updatePasscode:(NSString*) newPasscode forUser:(NSString*) userId {
    
    return NO;
}
- (BOOL) updatePassword:(NSString*) newPassword forUser:(NSString*) userId {
    
    return NO;
}



#pragma mark- CURRENCY

- (NSArray*) getAllCurrency {
    NSMutableArray *currencies = [[NSMutableArray alloc] init];
    
    NSArray *objects = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CurrencyDefinition" ofType:@"plist"]];
    // map to currency object
    for (NSDictionary *obj in objects) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[obj valueForKey:@"image"] ofType:@"png"];
        
        Currency *currency = [[Currency alloc] init];
        // (objectId text primary key, name text, symbol text, image text
        
        currency.objectId = [obj valueForKey:@"objectId"];
        currency.name = [obj valueForKey:@"name"];
        currency.symbol = [obj valueForKey:@"symbol"];
        currency.image = filePath;
        
        [currencies addObject:currency];
    }
    
    return currencies;
}

#pragma mark- CATEGORY

- (NSArray*) getAllCategory {
    NSMutableArray *categories = [[NSMutableArray alloc] init];
    
    NSArray *objects = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CategoryDefinition" ofType:@"plist"]];
    // map to currency object
    for (NSDictionary *obj in objects) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:[obj valueForKey:@"icon"] ofType:@"png"];
        
        Category *category = [[Category alloc] init];
        // (objectId text primary key, vnName text, enName text, icon text)
        
        category.objectId = [obj valueForKey:@"objectId"];
        category.vnName = [obj valueForKey:@"vnName"];
        category.enName = [obj valueForKey:@"enName"];
        category.icon = filePath;
        
        [categories addObject:category];
    }
    
    return categories;
}

#pragma mark- SELECT

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
        
        char * errMsg;
        int result = sqlite3_exec(database, [insertSQL UTF8String], NULL, NULL, &errMsg);
        if(result != SQLITE_OK) {
            NSLog(@"Failed to insert record  rc:%d, msg=%s",result,errMsg);
        }
        
        sqlite3_close(database);
    }
}

- (void) deleteTransactionWithObjectId:(NSString*) objectId {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString * query  = [NSString stringWithFormat:@"DELETE FROM TRANSACTION_TABLE WHERE objectId=\"%@\"", objectId];
        char * errMsg;
        int rc = sqlite3_exec(database, [query UTF8String] ,NULL,NULL,&errMsg);
        if(rc != SQLITE_OK) {
            NSLog(@"Failed to delete record  rc:%d, msg=%s",rc,errMsg);
        }
        sqlite3_close(database);
    }
}

- (NSArray*) selectTransactionByPage:(int) page category:(NSString*) categoryId fromDate:(NSDate*) fromDate toDate:(NSDate*) toDate {
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSMutableArray *transactions = [[NSMutableArray alloc] init];
        
        // where statement
        NSString *whereStm = @" 1 = 1";
        if (categoryId != nil) {
            whereStm = [NSString stringWithFormat:@"%@ AND categoryId = \"%@\"", whereStm, categoryId];
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATE_FORMATTER_IN_DB;
        
        if (fromDate != nil) {
            NSString *dateString = [formatter stringFromDate:fromDate];
            whereStm = [NSString stringWithFormat:@"%@ AND date >= \"%@\"", whereStm, dateString];
        }
        
        if (toDate != nil) {
            NSString *dateString = [formatter stringFromDate:toDate];
            whereStm = [NSString stringWithFormat:@"%@ AND date <= \"%@\"", whereStm, dateString];
        }
        
        // limit
        NSString *limit = [NSString stringWithFormat:@" LIMIT %d OFFSET %d", ITEMS_PER_PAGE, (page - 1) * ITEMS_PER_PAGE];
        
        // select query
        NSString *query = [NSString stringWithFormat: @"SELECT * from RMTRANSACTION WHERE %@ %@", whereStm, limit];
        
        
        // execute
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW) {
                //get each row in loop
                for (int i = 1; i<=7; i++) {
                    NSString *text = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, i)];
                    NSLog(@"[%d]. %@", i, text);
                }
                
                //                                        NSString * name =[NSString stringWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
                //                                        NSInteger age =  sqlite3_column_int(stmt, 2);
                //                                        NSInteger marks =  sqlite3_column_int(stmt, 3);
                //
                //                                        NSDictionary *student =[NSDictionary dictionaryWithObjectsAndKeys:name,@"name",
                //                                                                                                        [NSNumber numberWithInteger:age],@"age",[NSNumber numberWithInteger:marks], @"marks",nil];
                //
                //                                        [students addObject:student];
            }
            NSLog(@"Done");
            sqlite3_finalize(statement);
            
            return  transactions;
        } else {
            NSLog(@"Failed to prepare statement with rc:%d",rc);
        }
        
        sqlite3_close(database);
    }
    return nil;
}


@end

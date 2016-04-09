//
//  RMDataManagement.m
//  RickyMoney
//
//  Created by Thu Trang on 4/6/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMDataManagement.h"
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
        
        [self createCategoryData];
        [self createCurrencyData];
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
    autoId = [NSString stringWithFormat:@"RM_%@_%@", [tableName substringToIndex:2], autoId];
    
    return autoId;
}

- (void) createCategoryData {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSArray *objects = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CategoryDefinition" ofType:@"plist"]];
        for (NSDictionary *obj in objects) {
            NSString *objectId = [obj valueForKey:@"objectId"];
            NSString *vnName = [obj valueForKey:@"vnName"];
            NSString *enName = [obj valueForKey:@"enName"];
            NSString *icon = [[NSBundle mainBundle] pathForResource:[obj valueForKey:@"icon"] ofType:@"png"];
            
            NSString *insertQuery = @"insert into %@ (objectId, vnName, enName, icon) values (\"%@\", \"%@\", \"%@\", \"%@\")";
            insertQuery = [NSString stringWithFormat:insertQuery, CATEGORY_TABLE_NAME, objectId, vnName, enName, icon];
            
            char * errMsg;
            if (sqlite3_exec(database, [insertQuery UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Failed to Insert CATEGORY table: %s", errMsg);
            }
        }
        sqlite3_close(database);
    }
}

- (void) createCurrencyData {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSArray *objects = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CurrencyDefinition" ofType:@"plist"]];
        for (NSDictionary *obj in objects) {
            NSString *objectId = [obj valueForKey:@"objectId"];
            NSString *name = [obj valueForKey:@"name"];
            NSString *symbol = [obj valueForKey:@"symbol"];
            NSString *image = [[NSBundle mainBundle] pathForResource:[obj valueForKey:@"image"] ofType:@"png"];
            
            //(objectId text primary key, name text, symbol text, image text)"
            
            NSString *insertQuery = @"insert into %@ (objectId, name, symbol, image) values (\"%@\", \"%@\", \"%@\", \"%@\")";
            insertQuery = [NSString stringWithFormat:insertQuery, CURRENCY_TABLE_NAME, objectId, name, symbol, image];
            
            char * errMsg;
            if (sqlite3_exec(database, [insertQuery UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog(@"Failed to Insert CURRENCY table: %s", errMsg);
            }
        }
        sqlite3_close(database);
    }
}


#pragma mark- USER

- (NSString*) createNewUserWithEmail:(NSString *) email password:(NSString*) password {
    NSString *createdUserId = nil; // result is the created user id
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        // 1. Check exists email
        NSString *query = [NSString stringWithFormat: @"SELECT objectId from %@ WHERE email = \"%@\"", USER_TABLE_NAME, email];
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK){
            if (sqlite3_step(statement) == SQLITE_ROW) {
                NSLog(@"Email %@ is already taken", email);
                
                sqlite3_finalize(statement);
                sqlite3_close(database);
                
                return nil;
                
            } else {
                sqlite3_finalize(statement);
            }
        }
        
        // 2. Create new account
        
        NSString *userId = [self createAutoIdentifierForTable: USER_TABLE_NAME];
        NSString *insertQuery = [NSString stringWithFormat:@"insert into %@ (objectId, email, password, currencyId) values (\"%@\", \"%@\", \"%@\", \"RMCurreny_01\")", USER_TABLE_NAME, userId, email, password];
        
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
    NSString *userId = nil;
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        // select query
        NSString *query = [NSString stringWithFormat: @"SELECT objectId from %@ WHERE email = \"%@\" AND password = \"%@\"", USER_TABLE_NAME, email, password];
        
        // execute
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW) {
                userId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                
                // set that userId as a current user
                [[NSUserDefaults standardUserDefaults] setObject:userId forKey:CURRENT_USER_ID];
                
                NSLog(@"Login Success with userId = %@", userId);
            }
            sqlite3_finalize(statement);
            
        } else {
            NSLog(@"Failed to prepare statement with rc:%d",rc);
        }
        
        sqlite3_close(database);
    }
    
    return userId;
}

- (NSString*) getCurrentUserId {
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    NSString *currentUserId = [udf objectForKey:CURRENT_USER_ID];
    return currentUserId;
}

- (User*) getCurrentUserInfo {
    User *currentUser = nil;
    NSString *userId = [self getCurrentUserId];
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *query = [NSString stringWithFormat: @"SELECT * from %@ WHERE objectId = \"%@\"", USER_TABLE_NAME, userId];
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK){
            if (sqlite3_step(statement) == SQLITE_ROW) {
                currentUser = [[User alloc] init];
                //  (objectId text primary key, email text, password text, currencyId text, avatar text, passcode text)
                currentUser.objectId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                currentUser.email = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                currentUser.password = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                currentUser.currencyId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                currentUser.avatar = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                currentUser.passcode = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return currentUser;
}

- (NSString*) getCurrentUserCurrencySymbol {
    NSString *currency = nil;
    //    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
    //        NSString *userId = [self getCurrentUserId];
    //        NSString *query = [NSString stringWithFormat: @"SELECT * from %@ WHERE objectId = \"%@\"", USER_TABLE_NAME, userId];
    //        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
    //
    //        sqlite3_finalize(statement);
    //        sqlite3_close(database);
    //    }
    return currency;
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
    NSMutableArray *results = nil;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        NSString *query = [NSString stringWithFormat:@"select * from %@", CURRENCY_TABLE_NAME];
        
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            results = [[NSMutableArray alloc] init];
            
            //get each row in loop
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Currency *currency = [[Currency alloc] init];
                // (objectId text primary key, name text, symbol text, image text
                
                currency.objectId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                currency.name = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                currency.symbol = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                currency.image = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                
                [results addObject:currency];
            }
        } else {
            NSLog(@"Failed to get list CURRENCY");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return results;
}

#pragma mark- CATEGORY

- (NSArray*) getAllCategory {
    NSMutableArray *results = nil;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        NSString *query = [NSString stringWithFormat:@"select * from %@", CATEGORY_TABLE_NAME];
        
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            results = [[NSMutableArray alloc] init];
            
            //get each row in loop
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Category *category = [[Category alloc] init];
                // (objectId text primary key, vnName text, enName text, icon text)
                
                category.objectId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                category.vnName = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                category.enName = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                category.icon = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                
                [results addObject:category];
            }
        } else {
            NSLog(@"Failed to get list CATEGORY");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return results;
}

#pragma mark- TRANSACTION

- (NSString*) createNewTransaction:(Transaction*) newTransaction {
    NSString *objectId = nil;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        objectId = [self createAutoIdentifierForTable:TRANSACTION_TABLE_NAME];
        NSString *userId = [self getCurrentUserId];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATE_FORMATTER_IN_DB;
        NSString *transactionDate = [formatter stringFromDate:newTransaction.date];
        
        // (objectId text primary key, userId text, categoryId text, item text, amount real, notes text, date text, type integer)
        NSString *insertQuery = [NSString stringWithFormat:@"insert into %@ (objectId, userId, categoryId, item, amount, notes, date, type) values (\"%@\", \"%@\", \"%@\",\"%@\", %.2f, \"%@\", \"%@\", %d)", TRANSACTION_TABLE_NAME, objectId, userId, newTransaction.categoryId, newTransaction.item, newTransaction.amount, newTransaction.notes, transactionDate, newTransaction.type];
        
        char * errMsg;
        int result = sqlite3_exec(database, [insertQuery UTF8String], NULL, NULL, &errMsg);
        if(result != SQLITE_OK) {
            NSLog(@"Failed to insert TRANSACTION record: %s", errMsg);
            objectId = nil;
        } else {
            NSLog(@"Insert new TRANSACTION[%@] successfully", objectId);
        }
        
        sqlite3_close(database);
    }
    return objectId;
}


- (BOOL) updateTransaction:(Transaction*) updatedTransaction {
    
    return NO;
}
- (BOOL) deleteTransaction:(NSString*) transactionId {
    
    return NO;
}
- (NSArray*) getTransactionsByPage:(int) page category:(NSString*) categoryId type:(TransactionType) type {
    
    if (page < 1) {
        return nil;
    }
    
    NSMutableArray *results = nil;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        NSString *userId = [self getCurrentUserId];
        
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE userId = \"%@\" AND type = %d ", TRANSACTION_TABLE_NAME, userId, (type == EXPENSE) ? 0 : 1];
        
        if (categoryId != nil) {
            query = [NSString stringWithFormat:@"%@ AND categoryId = \"%@\" ", query, categoryId];
        }
        query = [NSString stringWithFormat:@"%@ LIMIT %d OFFSET %d", query, ITEMS_PER_PAGE, (page - 1) * ITEMS_PER_PAGE];
        
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
            results = [[NSMutableArray alloc] init];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = DATE_FORMATTER_IN_DB;
            
            //get each row in loop
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *transactionDate = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                
                Transaction *ts = [[Transaction alloc] init];
                // (objectId text primary key, userId text, categoryId text, item text, amount real, notes text, date text, type integer)
                ts.objectId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                ts.userId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                ts.categoryId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                ts.item = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                ts.amount = (float) sqlite3_column_double(statement, 4);
                ts.notes = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                ts.date = [formatter dateFromString:transactionDate];
                ts.type = sqlite3_column_int(statement, 7);
                
                [results addObject:ts];
            }
        } else {
            NSLog(@"Failed to getTransactionsByPage %d", page);
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return results;
}

- (Transaction*) getTransactionDetail:(NSString*) transactionId {
    Transaction *ts = nil;
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *query = [NSString stringWithFormat: @"SELECT A.*, B.enName from %@ as A INNER JOIN %@ as B ON A.categoryId = B.objectId WHERE A.objectId = \"%@\"", TRANSACTION_TABLE_NAME, CATEGORY_TABLE_NAME, transactionId];
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK){
            if (sqlite3_step(statement) == SQLITE_ROW) {
                ts = [[Transaction alloc] init];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = DATE_FORMATTER_IN_DB;
                NSString *transactionDate = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                
                // (objectId text primary key, userId text, categoryId text, item text, amount real, notes text, date text, type integer)
                ts.objectId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                ts.userId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                ts.categoryId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                ts.item = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                ts.amount = (float) sqlite3_column_double(statement, 4);
                ts.notes = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                ts.date = [formatter dateFromString:transactionDate];
                ts.type = sqlite3_column_int(statement, 7);
                ts.categoryName = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 8)];
                
            } else {
                NSLog(@"There is no data for TRANSACTION [%@]", transactionId);
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return ts;
}

#pragma mark- BUDGET

- (NSArray*) getAllBudget {
    
    return nil;
}
- (BOOL) createNewBudget:(float) budget forCategory:(NSString*) categoryId withDateUnit:(NSString*) dateUnit {
    
    return NO;
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

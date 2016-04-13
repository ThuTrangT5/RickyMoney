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
    
//    [self deleteTable:BUDGET_TABLE_NAME];

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

- (void) deleteTable:(NSString*) tableName {
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        NSString *createQuery = [NSString stringWithFormat: @"Delete from %@", tableName];
        char * errMsg;
        if (sqlite3_exec(database, [createQuery UTF8String], NULL, NULL, &errMsg) != SQLITE_OK) {
            NSLog(@"Failed to Delete table[%@]: %s", tableName, errMsg);
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
            NSString *icon = [obj valueForKey:@"icon"];
            
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
            NSString *image = [obj valueForKey:@"image"];
            
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

#pragma mark- BASE64 <=> Image

+ (NSString *)encodeToBase64String:(UIImage *)image {
    NSString *base64String = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return base64String;
}

+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

#pragma mark- MESSAGE

+ (void) showMessage:(NSString*) message withTitle:(NSString*) title {
   
    
//    [alert add]
    //[[UNAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
}

#pragma mark- USER

- (NSString*) createNewUserWithEmail:(NSString *) email password:(NSString*) password {
    NSString *userId = nil; // result is the created user id
    
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
        
        userId = [self createAutoIdentifierForTable: USER_TABLE_NAME];
        NSString *insertQuery = [NSString stringWithFormat:@"insert into %@ (objectId, email, password, currencyId) values (\"%@\", \"%@\", \"%@\", \"RMCurrency_01\")", USER_TABLE_NAME, userId, email, password];
        
        char * errMsg;
        int result = sqlite3_exec(database, [insertQuery UTF8String], NULL, NULL, &errMsg);
        if(result != SQLITE_OK) {
            NSLog(@"Failed to insert record  rc:%d, msg=%s",result,errMsg);
            userId = nil;
            
        } else {
            NSLog(@"Insert new User(%@, %@) successfully", userId, email);
        }
        
        sqlite3_close(database);
    }
    
    return userId;
}

- (NSString*) loginWithEmail:(NSString*) email andPassword:(NSString*) password {
    NSString *userId = nil;
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        // select query
        NSString *query = [NSString stringWithFormat: @"SELECT objectId, passcode from %@ WHERE email = \"%@\" AND password = \"%@\"", USER_TABLE_NAME, email, password];
        
        // execute
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW) {
                userId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                
                // check passcode
                const char *passcode = (const char *) sqlite3_column_text(statement, 1);
                if (passcode != nil) {
                    [[NSUserDefaults standardUserDefaults] setValue: [NSString stringWithUTF8String:passcode] forKey:CURRENT_PASSCODE];
                }
                
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
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_USER_ID];
    return currentUserId;
}

- (User*) getCurrentUserDetail {
    User *currentUser = nil;
    NSString *userId = [self getCurrentUserId];
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *query = [NSString stringWithFormat: @"SELECT A.*, B.name, B.symbol from %@ as A LEFT JOIN %@ as B ON A.currencyId = B.objectId WHERE A.objectId = \"%@\"", USER_TABLE_NAME, CURRENCY_TABLE_NAME, userId];
        
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK){
            if (sqlite3_step(statement) == SQLITE_ROW) {
                currentUser = [[User alloc] init];
                //  (objectId text primary key, email text, password text, currencyId text, avatar text, passcode text)
                currentUser.objectId = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                currentUser.email = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                currentUser.password = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                
                const char *tempChar = (const char *) sqlite3_column_text(statement, 3);
                if (tempChar != nil) {
                    currentUser.currencyId = [NSString stringWithUTF8String:tempChar];
                }
                
                tempChar = (const char *) sqlite3_column_text(statement, 4);
                if (tempChar != nil) {
                    currentUser.avatar = [NSString stringWithUTF8String:tempChar];
                }
                
                tempChar = (const char *) sqlite3_column_text(statement, 5);
                if (tempChar != nil) {
                    currentUser.passcode = [NSString stringWithUTF8String:tempChar];
                }
                
                tempChar = (const char *) sqlite3_column_text(statement, 6);
                if (tempChar != nil) {
                    currentUser.currencyName = [NSString stringWithUTF8String:tempChar];
                }
                
                tempChar = (const char *) sqlite3_column_text(statement, 7);
                if (tempChar != nil) {
                    currentUser.currencySymbol = [NSString stringWithUTF8String:tempChar];
                }
            }
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return currentUser;
}

- (NSString*) getCurrentUserCurrencySymbol {
    NSString *currency = @"";
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *userId = [self getCurrentUserId];
        NSString *query = [NSString stringWithFormat: @"SELECT B.symbol from %@ as A INNER JOIN %@ as B ON A.currencyId = B.objectId WHERE A.objectId = \"%@\"", USER_TABLE_NAME, CURRENCY_TABLE_NAME, userId];
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if (rc == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                currency = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return currency;
}

- (BOOL) updateCurrency:(NSString*) currencyId forUser:(NSString *) userId {
    BOOL result = NO;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *updateQuery = @"update %@ set currencyId = \"%@\" where objectId = \"%@\"";
        updateQuery = [NSString stringWithFormat:updateQuery, USER_TABLE_NAME, currencyId, userId];
        
        char * errMsg;
        int rc = sqlite3_exec(database, [updateQuery UTF8String], NULL, NULL, &errMsg);
        if(rc != SQLITE_OK) {
            NSLog(@"Failed to update Currency for USER[%@] record: %s", userId, errMsg);
        } else {
            NSLog(@"Update Currency for USER[%@] successfully", userId);
            result = YES;
        }
        
        sqlite3_close(database);
    }
    
    return result;
}

- (BOOL) updateAvatar:(UIImage*) avatar forUser:(NSString*) userId {
    BOOL result = NO;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *imageBase64String = [RMDataManagement encodeToBase64String:avatar];
        NSString *updateQuery = @"update %@ set avatar = \"%@\" where objectId = \"%@\"";
        updateQuery = [NSString stringWithFormat:updateQuery, USER_TABLE_NAME, imageBase64String, userId];
        
        char * errMsg;
        int rc = sqlite3_exec(database, [updateQuery UTF8String], NULL, NULL, &errMsg);
        if(rc != SQLITE_OK) {
            NSLog(@"Failed to update Avatar for USER[%@] record: %s", userId, errMsg);
        } else {
            NSLog(@"Update Avatar for USER[%@] successfully", userId);
            result = YES;
        }
        
        sqlite3_close(database);
    }
    return result;
}

- (BOOL) updatePasscode:(NSString*) newPasscode forUser:(NSString*) userId {
    BOOL result = NO;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *updateQuery;
        if (newPasscode == nil) {
            updateQuery = @"update %@ set passcode = null where objectId = \"%@\"";
            updateQuery = [NSString stringWithFormat:updateQuery, USER_TABLE_NAME, userId];
            
        } else {
            updateQuery = @"update %@ set passcode = \"%@\" where objectId = \"%@\"";
            updateQuery = [NSString stringWithFormat:updateQuery, USER_TABLE_NAME, newPasscode, userId];
        }
        
        char * errMsg;
        int rc = sqlite3_exec(database, [updateQuery UTF8String], NULL, NULL, &errMsg);
        if(rc != SQLITE_OK) {
            NSLog(@"Failed to update PASSCODE for USER[%@] record: %s", userId, errMsg);
        } else {
            NSLog(@"Update PASSCODE for USER[%@] successfully", userId);
            result = YES;
        }
        
        sqlite3_close(database);
    }
    return result;
}

- (BOOL) updatePassword:(NSString*) newPassword forUser:(NSString*) userId {
    BOOL result = NO;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSString *updateQuery = @"update %@ set password = \"%@\" where objectId = \"%@\"";
        updateQuery = [NSString stringWithFormat:updateQuery, USER_TABLE_NAME, newPassword, userId];
        
        char * errMsg;
        int rc = sqlite3_exec(database, [updateQuery UTF8String], NULL, NULL, &errMsg);
        if(rc != SQLITE_OK) {
            NSLog(@"Failed to update PASSWORD for USER[%@] record: %s", userId, errMsg);
        } else {
            NSLog(@"Update PASSWORD for USER[%@] successfully", userId);
            result = YES;
        }
        
        sqlite3_close(database);
    }
    return result;
}

#pragma mark- CURRENCY

- (NSArray*) getAllCurrency {
    NSMutableArray *results = nil;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        NSString *query = [NSString stringWithFormat:@"select * from %@ order by objectId", CURRENCY_TABLE_NAME];
        
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
        
        NSString *query = [NSString stringWithFormat:@"select * from %@ order by enName", CATEGORY_TABLE_NAME];
        
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
    BOOL result = NO;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATE_FORMATTER_IN_DB;
        NSString *transactionDate = [formatter stringFromDate:updatedTransaction.date];
        
        // (objectId text primary key, userId text, categoryId text, item text, amount real, notes text, date text, type integer)
        NSString *updateQuery = @"update %@ set categoryId = \"%@\", item = \"%@\", amount = %.2f, notes = \"%@\", date = \"%@\", type = %d where objectId = \"%@\"";
        updateQuery = [NSString stringWithFormat:updateQuery, TRANSACTION_TABLE_NAME,
                       updatedTransaction.categoryId,
                       updatedTransaction.item,
                       updatedTransaction.amount,
                       updatedTransaction.notes,
                       transactionDate,
                       updatedTransaction.type,
                       updatedTransaction.objectId];
        
        char * errMsg;
        int rc = sqlite3_exec(database, [updateQuery UTF8String], NULL, NULL, &errMsg);
        if(rc != SQLITE_OK) {
            NSLog(@"Failed to update TRANSACTION[%@] record: %s", updatedTransaction.objectId, errMsg);
        } else {
            NSLog(@"Update TRANSACTION[%@] successfully", updatedTransaction.objectId);
            result = YES;
        }
        
        sqlite3_close(database);
    }
    return result;
}

- (BOOL) deleteTransaction:(NSString*) transactionId {
    BOOL result = NO;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        NSString * query  = [NSString stringWithFormat:@"delete from %@ where objectId=\"%@\"", TRANSACTION_TABLE_NAME, transactionId];
        char * errMsg;
        int rc = sqlite3_exec(database, [query UTF8String] ,NULL,NULL,&errMsg);
        
        if(rc != SQLITE_OK) {
            NSLog(@"Failed to delete TRANSACTION[%@] : %s",transactionId,errMsg);
        } else {
            result = YES;
        }
        
        sqlite3_close(database);
    }
    return result;
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

- (NSArray*) reviewTransactionFromDate:(NSString*)fromDate toDate:(NSString*) toDate {
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        NSString *query = @"select sum(A.amount), B.enName, A.type from %@ as A INNER JOIN %@ as B ON A.categoryId = B.objectId";
        query = [query stringByAppendingString: @" where A.userId = \"%@\"  and A.date >= \"%@\" and A.date <= \"%@\" "];
        query = [query stringByAppendingString: @" group by A.categoryId, A.type"];
        query = [query stringByAppendingString: @" order by B.enName"];
        
        query = [NSString stringWithFormat:query, TRANSACTION_TABLE_NAME, CATEGORY_TABLE_NAME, [self getCurrentUserId], fromDate, toDate];
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK){
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *amount = [NSString stringWithFormat:@"%.2f", (float) sqlite3_column_double(statement, 0)];
                NSString *categoryName = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSString *type = [NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 2)];
                
                NSDictionary *record = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        categoryName, @"categoryName",
                                        amount, @"amount",
                                        type, @"type",
                                        nil];
                
                [results addObject:record];
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        return results;
        
    }
    
    return nil;
}

#pragma mark- BUDGET

- (NSArray*) getAllBudgetsFromDate:(NSString*)fromDate toDate:(NSString*) toDate {
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        
        // get number of days between fromDate and to Date
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATE_FORMATTER_IN_DB;
        NSDate *date2 = [formatter dateFromString:toDate];
        
        int days = 30;
        if (date2 != nil) {
            
            NSDate *date1 = [formatter dateFromString:fromDate];
            
            NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                                fromDate:date1
                                                                  toDate:date2
                                                                 options:NSCalendarWrapComponents];
            days = (int)[components day] + 1;
        }
        //@"create table if not exists %@ (objectId text primary key, userId text, categoryId text, budget real, dateUnit
        
        NSString *query = @"select sum(A.amount), B.enName, C.budget from %@ as A, %@ as B, %@ as C ";
        query = [query stringByAppendingString:@" where A.categoryId = B.objectId and A.userId = C.userId and C.categoryId = B.objectId"];
        query = [query stringByAppendingString: @" and A.userId = \"%@\"  and A.date >= \"%@\" and A.date <= \"%@\" and type = 0 "];
        query = [query stringByAppendingString: @" group by A.categoryId"];
        query = [query stringByAppendingString: @" order by B.enName"];
        
        query = [NSString stringWithFormat:query, TRANSACTION_TABLE_NAME, CATEGORY_TABLE_NAME, BUDGET_TABLE_NAME, [self getCurrentUserId], fromDate, toDate];
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK){
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                float val = (float) sqlite3_column_double(statement, 2);
                val = val / 30.0 * days;
                
                NSString *expense = [NSString stringWithFormat:@"%.2f", (float) sqlite3_column_double(statement, 0)];
                NSString *categoryName = [NSString stringWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSString *budget = [NSString stringWithFormat:@"%.2f", val];
                
                NSDictionary *record = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        categoryName, @"categoryName",
                                        expense, @"expense",
                                        budget, @"budget",
                                        nil];
                
                [results addObject:record];
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        return results;
    }
    
    return nil;
}

- (BOOL) createNewBudget:(float) budget forCategory:(NSString*) categoryId {
    BOOL result = NO;
    
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        // (userId text, categoryId text, budget real, PRIMARY KEY (userId, categoryId))
        NSString *userId = [self getCurrentUserId];
        NSString *insertQuery = @"insert or replace into %@ (userId, categoryId, budget) values (\"%@\", \"%@\", %.2f)";
        insertQuery = [NSString stringWithFormat:insertQuery, BUDGET_TABLE_NAME, userId, categoryId, budget];
        
        char * errMsg;
        int result = sqlite3_exec(database, [insertQuery UTF8String], NULL, NULL, &errMsg);
        if(result != SQLITE_OK) {
            NSLog(@"Failed to insert TRANSACTION record: %s", errMsg);
    
        } else {
            NSLog(@"Insert new TRANSACTION[%@, %@] successfully", categoryId, userId);
            result = YES;
        }
        sqlite3_close(database);
        
        return result;
    }
    return result;
}

- (NSArray*) getAllBudgetsForEdit {
    if (sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        // BUDGET (userId text, categoryId text, budget real, PRIMARY KEY (userId, categoryId))
        // CATEGORY: (objectId text primary key, vnName text, enName text, icon text)"
        
        NSString *query = @"select A.objectId, A.enName, a.icon, C.userId, C.budget from %@ as A LEFT OUTER JOIN";
        query = [query stringByAppendingString:@" (select budget, userId, categoryId from %@ as B where B.userId = \"%@\") as C"];
        query = [query stringByAppendingString:@" ON A.objectId = C.categoryId"];
        query = [query stringByAppendingString:@" order by A.enName"];
        
        query = [NSString stringWithFormat:query, CATEGORY_TABLE_NAME, BUDGET_TABLE_NAME, [self getCurrentUserId]];
        
        NSMutableArray *results = [[NSMutableArray alloc] init];
        
        int rc = sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, NULL);
        if(rc == SQLITE_OK){
            while (sqlite3_step(statement) == SQLITE_ROW) {
                const char *catId = (const char*) sqlite3_column_text(statement, 0);
                const char *catName = (const char*) sqlite3_column_text(statement, 1);
                const char *catIcon = (const char*) sqlite3_column_text(statement, 2);
                const char *userId = (const char*) sqlite3_column_text(statement, 3);
                float budget =  sqlite3_column_double(statement, 4);
                
                Budget *object = [[Budget alloc] init];
                object.userId = (userId == nil) ? nil :[NSString stringWithUTF8String:userId];
                object.categoryId = (catId == nil) ? nil :[NSString stringWithUTF8String:catId];
                object.budget =  budget;
                object.categoryName = (catName == nil) ? nil :[NSString stringWithUTF8String:catName];
                object.categoryIcon = (catIcon == nil) ? nil :[NSString stringWithUTF8String:catIcon];
                
                [results addObject:object];
            }
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        return results;
        
    }
    
    return nil;
}

@end

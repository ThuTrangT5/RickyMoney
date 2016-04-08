//
//  RMObjects.h
//  RickyMoney
//
//  Created by Thu Trang on 4/8/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#ifndef RMObjects_h
#define RMObjects_h

#import "User.h"
#import "Currency.h"
#import "Category.h"
#import "Transaction.h"
#import "Budget.h"

#define DATABASE_FILE_NAME @"RM-DATABASE.DB"
#define ITEMS_PER_PAGE 25
#define DATE_FORMATTER_IN_DB @"YYYY-MM-DD"

#define USER_TABLE_NAME @"USER_TABLE"
#define CURRENCY_TABLE_NAME @"CURRENCY_TABLE"
#define CATEGORY_TABLE_NAME @"CATEGORY_TABLE"
#define TRANSACTION_TABLE_NAME @"TRANSACTION_TABLE"
#define BUDGET_TABLE_NAME @"BUDGET_TABLE"

#define CREATE_USER_TABLE_QUERY @"create table if not exists %@ (objectId text primary key, email text, password text, currencyId text, avatar text, passcode text)"
#define CREATE_CURRENCY_TABLE_QUERY @"create table if not exists %@ (objectId text primary key, name text, symbol text, image text)"
#define CREATE_CATEGORY_TABLE_QUERY @"create table if not exists %@ (objectId text primary key, vnName text, enName text, icon text)"
#define CREATE_TRANSACTION_TABLE_QUERY @"create table if not exists %@ (objectId text primary key, userId text, categoryId text, item text, amount real, notes text, date text, type integer)"
#define CREATE_BUDGET_TABLE_QUERY @"create table if not exists %@ (objectId text primary key, userId text, categoryId text, budget real, dateUnit text)"

#define CURRENT_USER_ID @"RM-CURRENT_USER_ID"

#endif /* RMObjects_h */

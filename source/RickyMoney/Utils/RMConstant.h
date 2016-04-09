//
//  RMConstant.h
//  RickyMoney
//
//  Created by Adelphatech on 9/5/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#ifndef RickyMoney_RMConstant_h
#define RickyMoney_RMConstant_h

#define RM_COLOR [UIColor colorWithRed:230.0/255.0 green:194.0/255.0 blue:32.0/255.0 alpha:1.0] // # e6c220

typedef enum _options {
    OPTION_PASSCODE,
    OPTION_CURRENCY,
    OPTION_CATEGORY
} OptionTypes;

typedef enum _timePeriod {
    WEEKLY,
    MONTHLY,
    YEARLY
} TimePeriod;

typedef enum _transactiontype {
    EXPENSE,
    INCOME
} TransactionType;

#define kInsertNewTransaction @"RM-kInsertNewTransaction"
#define kUpdateTransaction @"RM-kUpdateTransaction"
#define kUpdateCurrency @"RM-kUpdateCurrency"

//#define ITEM_PER_PAGE 20

#define PASSCODE_VIEW_STORYBOARD_KEY @"RM-PassCodeVC"

#define CURRENT_USER_ID @"RM-CURRENT_USER_ID"
#define LOGIN_DATE @"RM-LOGIN_DATE"
#define TIMEOUT_LOGIN_DAYS 7.0
#define CURRENT_PASSCODE @"RM-CURRENT_USER_ID"

#endif

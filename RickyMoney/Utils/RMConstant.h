//
//  RMConstant.h
//  RickyMoney
//
//  Created by Adelphatech on 9/5/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#ifndef RickyMoney_RMConstant_h
#define RickyMoney_RMConstant_h

#define RM_COLOR [UIColor colorWithRed:230.0/255.0 green:194.0/255.0 blue:32.0/255.0 alpha:1.0]

typedef enum _options {
    OPTION_PASSCODE,
    OPTION_CURRENCY,
    OPTION_PERIOD_TIME,
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

#define REPORT_OPTIONS @[@"Monthly", @"Quarterly", @"Yearly"]

#define kPasscode @"kPasscode"
#define kPasscodeOn @"Passcode is ON"
#define kPasscodeOff @"Passcode is OFF"

#define ITEM_PER_PAGE 20

#endif

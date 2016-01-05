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

#define REPORT_OPTIONS @[@"Monthly", @"Quarterly", @"Yearly"]

#endif

//
//  RMTransactionController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/10/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMConstant.h"

@interface RMTransactionController : UITableViewController {
    int currentPage;
}

@property (nonatomic) TransactionType transactionType;
@property (strong, nonatomic) NSString *category;
@property (strong, nonatomic) NSMutableArray *transactions;
@property (strong, nonatomic) NSDate *fromDate, *toDate;
@property (strong, nonatomic) NSString *currency;

- (IBAction)onchangeTransactionType:(UISegmentedControl *)sender;
@end

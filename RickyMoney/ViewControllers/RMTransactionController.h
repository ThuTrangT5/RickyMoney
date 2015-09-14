//
//  RMTransactionController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/10/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMTransactionController : UITableViewController {
    int currentPage;
}

@property (nonatomic) int transactionType;
@property (strong, nonatomic) NSMutableArray *transactions;

@end

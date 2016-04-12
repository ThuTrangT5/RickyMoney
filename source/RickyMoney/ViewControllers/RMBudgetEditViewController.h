//
//  RMBudgetEditViewController.h
//  RickyMoney
//
//  Created by Thu Trang on 4/10/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMBudgetEditViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *budgetData;
@property (strong, nonatomic) NSMutableDictionary *budgetUpdatedData;

- (IBAction)ontouchSave:(id)sender;

@end

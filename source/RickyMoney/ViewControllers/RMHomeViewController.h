//
//  RMHomeViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/5/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LMDropdownView/LMDropdownView.h>
#import "RMConstant.h"
#import "CZPicker.h"
#import "RMCalendar.h"
#import "RMOptionsViewController.h"

@interface RMHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CZPickerViewDataSource, CZPickerViewDelegate, RMCalendarDelegate, RMOptionsDelegate>

@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) NSMutableArray *expenseTransactions, *incomeTransactions;

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) LMDropdownView *dropdownView;
@property (weak, nonatomic) IBOutlet UIButton *rangeButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transactionType;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

- (IBAction)ontouchMenu:(id)sender;
- (IBAction)ontouchSelectRange:(UIButton *)sender;
- (IBAction)onchangeTransactionType:(UISegmentedControl*)sender;

@end

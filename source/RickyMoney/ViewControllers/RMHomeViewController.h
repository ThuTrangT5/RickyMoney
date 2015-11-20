//
//  RMHomeViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/5/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LMDropdownView/LMDropdownView.h>
#import "VBPieChart.h"
#import "RMConstant.h"

@interface RMHomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) NSMutableArray *expenseTransactions, *incomeTransactions;

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) LMDropdownView *dropdownView;
@property (weak, nonatomic) IBOutlet UIButton *rangeButton;

@property (strong, nonatomic) VBPieChart *chartView;
@property (nonatomic) TimePeriod timePeriod;

- (IBAction)ontouchMenu:(id)sender;
- (IBAction)ontouchSelectRange:(UIButton *)sender;
- (IBAction)onchangeTransactionType:(UISegmentedControl*)sender;

@end

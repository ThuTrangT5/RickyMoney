//
//  RMBudgetsViewController.h
//  RickyMoney
//
//  Created by Thu Trang on 4/10/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZPicker.h"
#import "RMCalendar.h"

@interface RMBudgetsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CZPickerViewDataSource, CZPickerViewDelegate, RMCalendarDelegate>

@property (strong, nonatomic) NSMutableArray *budgetData;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *rangeButton;

- (IBAction)ontouchSelectRange:(id)sender;
@end

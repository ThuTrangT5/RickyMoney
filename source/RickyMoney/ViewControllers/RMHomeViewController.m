//
//  RMHomeViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/5/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMHomeViewController.h"
#import "UIImage+FontAwesome.h"
#import "AppDelegate.h"
#import "UIColor+HexColor.h"
#import "RMParseRequestHandler.h"

@implementation RMHomeViewController {
    NSArray *pickerData;
    NSDate *_fromDate, *_toDate;
}

#define MENU_TABLE_TAG 10
#define TRANSACTION_TABLE_TAG 20

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _menuItems = [[NSArray alloc] initWithObjects:
                  @[@"fa-user", @"Profile"],
                  @[@"fa-pencil-square-o", @"Transactions"],
                  @[@"fa-tags", @"Categories"],
                  @[@"fa-bell", @"Notifications"],
                  @[@"fa-money", @"About RickyMoney"],
                  @[@"fa-question", @"Help"],
                  @[@"fa-sign-out", @"Sign out"],
                  nil];
    
    [_menuTableView setHidden:YES];
    [_menuTableView removeFromSuperview];
    
    // UI for menu bar button
    UIImage *menuicon = [UIImage imageWithIcon:@"fa-list-ul" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] andSize:CGSizeMake(25, 25)];
    [self.navigationItem.leftBarButtonItem setImage:menuicon];
    [self.navigationItem.leftBarButtonItem setTitle:@""];
    
    // data
    _expenseTransactions = [[NSMutableArray alloc] init];
    _incomeTransactions = [[NSMutableArray alloc] init];
    
    // chart
    [self initChart];
    
    // picker
    pickerData = [[NSArray alloc] initWithObjects:@"Today", @"This Week", @"This Month", @"Last Month", @"This Year", @"Custome", nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getTransactionByTimePeriod: @"This Month"];
}

#pragma mark - DropDownView

- (void)showDropDownView
{
    // Init dropdown view
    if (!self.dropdownView) {
        self.dropdownView = [LMDropdownView dropdownView];
        //        self.dropdownView.delegate = self;
        
        // Customize Dropdown style
        self.dropdownView.closedScale = 0.85;
        self.dropdownView.blurRadius = 5;
        self.dropdownView.blackMaskAlpha = 0.5;
        self.dropdownView.animationDuration = 0.3;
        self.dropdownView.animationBounceHeight = 20;
        
        
        CGRect frame = self.view.bounds;
        frame.size.height = 44 * (_menuItems.count);
        [self.menuTableView setFrame:frame];
        [self.menuTableView setHidden:NO];
    }
    
    // Show/hide dropdown view
    if ([self.dropdownView isOpen]) {
        [self.dropdownView hide];
    } else {
        [self.dropdownView showFromNavigationController:self.navigationController withContentView:self.menuTableView];
    }
}

#pragma mark- TableView datasource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView.tag == MENU_TABLE_TAG) {
        return 1;
    } else if (tableView.tag == TRANSACTION_TABLE_TAG) {
        return 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    NSArray *cellData = _menuItems[indexPath.row];
    
    UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
    [icon setContentMode:UIViewContentModeCenter];
    [icon setImage: [UIImage imageWithIcon:cellData[0] backgroundColor:[UIColor clearColor] iconColor: RM_COLOR andSize:CGSizeMake(30, 20)]];
    
    UILabel *item = (UILabel*) [cell viewWithTag:2];
    [item setText: cellData[1]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { // profile
        [self performSegueWithIdentifier:@"settingSegue" sender:nil];
        
    } else if (indexPath.row == 1) { // Transactions
        [self performSegueWithIdentifier:@"transactionSegue" sender:nil];
        
    } else if (indexPath.row == 2) { // category
        [self performSegueWithIdentifier:@"categorySegue" sender:nil];
        
    } else if (indexPath.row == 3) {
        
        
    } else if (indexPath.row == 4) {
        
        
    } else if (indexPath.row == 5) {
        
        
    } else if (indexPath.row == 6) {
        [PFUser logOut];
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logoutSuccess];
        
    }
}

#pragma mark- Chart
- (void) initChart {
    if (_chartView == nil) {
        _chartView = [[VBPieChart alloc] init];
        
        UIView *chartViewParent = [self.view viewWithTag:1];
        [chartViewParent setBackgroundColor:[UIColor clearColor]];
        [_chartView setFrame:chartViewParent.bounds];
        
        [chartViewParent addSubview:_chartView];
    }
    
    [_chartView setHoleRadiusPrecent:0.3]; /* hole inside of chart */
    //    [_chartView setEnableStrokeColor:YES];
    
    [_chartView setLabelsPosition:VBLabelsPositionOutChart];
    
}

#pragma mark- Get Transaction data

- (void) getTransactionByTimePeriod:(NSString*) timePeriod {
    /* NOTE FOR CLOUD CODE
     1. Formatter datetime is [MM/dd/yyyy]
     2. Get data with from & to is [from <= date < to]
     */
    
    NSString *from, *to;
    NSDate *today = [NSDate date];
    int day, month, year;
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    
    // for testing
    // [myFormatter setDateFormat:@"dd/MM/yyyy"];
    // today = [myFormatter dateFromString:@"27/12/2015"];
    
    [myFormatter setDateFormat:@"dd"];
    day = [[myFormatter stringFromDate:today] intValue];
    [myFormatter setDateFormat:@"MM"];
    month = [[myFormatter stringFromDate:today] intValue];
    [myFormatter setDateFormat:@"yyyy"];
    year = [[myFormatter stringFromDate:today] intValue];
    
    if ([timePeriod isEqualToString: pickerData[0]]) { // today
        from = [myFormatter stringFromDate:today];
        to = from;
        
    } else if ([timePeriod isEqualToString:pickerData[1]]) { // this week
        // weekly from sunday to saturday
        [myFormatter setDateFormat:@"c"];
        int dayOfWeek = [[myFormatter stringFromDate:today] intValue]; // 7 for Saturday
        
        // from date
        NSTimeInterval timeInterval = - (60 * 60 * 24 * (dayOfWeek - 1));
        NSDate *date = [today dateByAddingTimeInterval:timeInterval];
        
        [myFormatter setDateFormat:@"MM/dd/yyyy"];
        from = [myFormatter stringFromDate:date];
        
        // to date
        timeInterval = 60 * 60 * 24 * 7; // 7 days include [from date]
        date = [date dateByAddingTimeInterval:timeInterval];
        to = [myFormatter stringFromDate:date];
        
    } else if ([timePeriod isEqualToString:pickerData[2]]) { // this month
        from = [NSString stringWithFormat:@"%d/01/%d",month,year];
        if (month == 12) {
            to = [NSString stringWithFormat:@"01/01/%d", year + 1];
        } else {
            to = [NSString stringWithFormat:@"%d/01/%d", month + 1, year];
        }
        
    } else if ([timePeriod isEqualToString:pickerData[3]]) { // last month
        to = [NSString stringWithFormat:@"%d/01/%d", month, year];
        
        if (month == 1) {
            month = 12;
            year--;
        } else {
            month --;
        }
        from = [NSString stringWithFormat:@"%d/01/%d",month,year];
        
    } else if ([timePeriod isEqualToString:pickerData[4]]) { // this year
        from = [NSString stringWithFormat:@"01/01/%d",year];
        to = [NSString stringWithFormat:@"01/01/%d",year + 1];
    }
    
    [self getTransactionFromDate:from toDate:to];
}

- (void) getTransactionFromDate:(NSString*) fromDate toDate:(NSString*) toDate {
    // format of date is dd/mm/yyyy
    
    NSArray *objs = [[NSArray alloc] initWithObjects:[PFUser currentUser].objectId, @"ENName", fromDate, fromDate, nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"userId", @"language", @"fromDate", @"toDate", nil];
    NSDictionary *params = [[NSDictionary alloc] initWithObjects: objs forKeys: keys];
    
    [RMParseRequestHandler callFunction:@"transactionReview" WithParams:params withSuccessBlock:^(NSDictionary *trans) {
        [_expenseTransactions removeAllObjects];
        
        NSDictionary *expense = [trans valueForKey:@"expense"];
        for (NSString *categoryId in [expense allKeys]) {
            NSDictionary *tran = [expense valueForKey:categoryId];
            NSDictionary *chart = @{
                                    @"name": [tran valueForKey:@"name"],
                                    @"value": [tran valueForKey:@"amount"],
                                    @"labelColor": RM_COLOR
                                    };
            [_expenseTransactions addObject:chart];
        }
        
        [_incomeTransactions removeAllObjects];
        NSDictionary *income = [trans valueForKey:@"income"];
        for (NSString *categoryId in [income allKeys]) {
            NSDictionary *tran = [income valueForKey:categoryId];
            NSDictionary *chart = @{
                                    @"name": [tran valueForKey:@"name"],
                                    @"value": [tran valueForKey:@"amount"],
                                    @"labelColor": RM_COLOR
                                    };
            [_incomeTransactions addObject:chart];
        }
        
        [_chartView setChartValues:_expenseTransactions animation:YES];
    }];
}

- (void) getTransactionsByCategory {
    PFQuery *query = [PFQuery queryWithClassName:@"Transaction"];
    [query whereKey:@"userId" equalTo:[[PFUser currentUser] objectId]];
}

#pragma mark- PickerView

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return pickerData.count;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView titleForRow:(NSInteger)row {
    return pickerData[row];
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    [self.rangeButton setTitle:pickerData[row] forState:UIControlStateNormal];
    
    if ([pickerData[row] isEqualToString:@"Custome"]) {
        _fromDate = nil;
        _toDate = nil;
        [self showCalendar];
        
    } else {
        [self getTransactionByTimePeriod:pickerData[row]];
    }
}

- (void) showPicker {
    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Select Date Range" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Select" mainColor:RM_COLOR];
    picker.delegate = self;
    picker.dataSource = self;
    picker.needFooterView = NO;
    [picker show];
}

#pragma mark- Calendar

- (void) showCalendar {
    RMCalendar *calendar = [[RMCalendar alloc] initCalendarWithTitle:@"Date from ... " andConfirmButton:@"Next"];
    calendar.delegate = self;
    [calendar show];
}

- (void)RMCalendar:(RMCalendar *)calendar didSelectDate:(NSDate *)selectedDate {
    if (_fromDate == nil) {
        calendar.titleView.text = @"to date ...";
        [calendar.confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        _fromDate = selectedDate;
    } else {
        _toDate = selectedDate;
        [calendar hide];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        [self getTransactionFromDate:[formatter stringFromDate:_fromDate] toDate:[formatter stringFromDate:_toDate]];
    }
}

#pragma mark- Actions

- (IBAction)ontouchMenu:(id)sender {
    [self.menuTableView reloadData];
    [self showDropDownView];
}

- (IBAction)ontouchSelectRange:(UIButton *)sender {
    [self showPicker];
}

- (IBAction)onchangeTransactionType:(UISegmentedControl*)sender {
    NSMutableArray *selectedData = nil;
    if (sender.selectedSegmentIndex == 0) {
        selectedData = _expenseTransactions;
        
    } else if (sender.selectedSegmentIndex == 1) {
        selectedData = _incomeTransactions;
    }
    
    if (selectedData.count > 0) {
        [_chartView setHidden:NO];
        [_chartView setChartValues: selectedData animation:YES];
    } else {
        [_chartView setHidden:YES];
    }
}
@end

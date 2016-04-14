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
#import "RMTransactionController.h"
#import "RMDataManagement.h"
#import "TTAlertView.h"
#import "MDTableViewCell.h"

#import "RickyMoney-Swift.h"

@interface RMHomeViewController () <MDRotatingPieChartDataSource>

@end

@implementation RMHomeViewController {
    NSArray *pickerData;
    NSDate *_fromDate, *_toDate;
    
    MDRotatingPieChart *_chartView;
    NSArray *_chartData, *_chartColor;
    NSString *currency;
}

#define MENU_TABLE_TAG 10
#define TRANSACTION_TABLE_TAG 20

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _menuItems = [[NSArray alloc] initWithObjects:
                  @[@"fa-cogs", @"Setting"],
                  @[@"fa-pencil-square-o", @"Transactions"],
                  @[@"fa-tags", @"Categories"],
                  @[@"fa-tasks", @"Budgets"],
                  @[@"fa-money", @"About RickyMoney"],
                  @[@"fa-sign-out", @"Sign out"],
                  nil];
    
    [_menuTableView setHidden:YES];
    [_menuTableView removeFromSuperview];
    
    // UI for menu bar button
    UIImage *menuicon = [UIImage imageWithIcon:@"fa-list-ul" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] andSize:CGSizeMake(25, 25)];
    [self.navigationItem.leftBarButtonItem setImage:menuicon];
    [self.navigationItem.leftBarButtonItem setTitle:@""];
    
    // insert calendar image for range button
    CGSize size = CGSizeMake(20, 20);
    UIImage *calendarImg = [UIImage imageWithIcon:@"fa-calendar" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] andSize:size];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [imgView setImage:calendarImg];
    [_rangeButton addSubview:imgView];
    
    // data
    _expenseTransactions = [[NSMutableArray alloc] init];
    _incomeTransactions = [[NSMutableArray alloc] init];
    _chartData = [[NSArray alloc] init];
    [_noDataLabel setHidden:YES];
    
    // picker
    pickerData = [[NSArray alloc] initWithObjects:@"Today", @"This Week", @"This Month", @"Last Month", @"This Year", @"Custome", nil];
    
    // currency
    [self getUserCurrency];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectUpdateCurrency:) name:kUpdateCurrency object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getTransactionByTimePeriod: _rangeButton.titleLabel.text];
}

#pragma mark - DropDownView

- (void)showDropDownView
{
    // Init dropdown view
    if (!self.dropdownView) {
        self.dropdownView = [LMDropdownView dropdownView];
        // Customize Dropdown style
        self.dropdownView.closedScale = 0.85;
        self.dropdownView.blurRadius = 5;
        self.dropdownView.blackMaskAlpha = 0.5;
        self.dropdownView.animationDuration = 0.3;
        self.dropdownView.animationBounceHeight = 20;
        
        
        CGRect frame = self.view.bounds;
        frame.size.height = self.menuTableView.rowHeight * (_menuItems.count);
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
    MDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    NSArray *cellData = _menuItems[indexPath.row];
    
    UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
    [icon setContentMode:UIViewContentModeCenter];
    [icon setImage: [UIImage imageWithIcon:cellData[0] backgroundColor:[UIColor clearColor] iconColor: RM_COLOR andSize:CGSizeMake(40, 25)]];
    
    UILabel *item = (UILabel*) [cell viewWithTag:2];
    [item setText: cellData[1]];
    
    cell.rippleColor = RM_COLOR;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    double delayInSeconds = 0.35;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (indexPath.row == 0) { // profile
            [self performSegueWithIdentifier:@"settingSegue" sender:nil];
            
        } else if (indexPath.row == 1) { // Transactions
            [self performSegueWithIdentifier:@"transactionSegue" sender:nil];
            
        } else if (indexPath.row == 2) { // category
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            UIViewController *category = [mainStoryboard instantiateViewControllerWithIdentifier: @"OptionsVC"];
            [self.navigationController pushViewController: category animated: YES];
            
        } else if (indexPath.row == 3) { // budget
            [self performSegueWithIdentifier:@"budgetSegue" sender:nil];
            
        } else if (indexPath.row == 4) { // about
            
        } else if (indexPath.row == 5) { // sign out
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] logoutSuccess];
            
        }
        
    });
}

#pragma mark- Chart
- (void) initChart {
    
    _chartColor = [[NSArray alloc] initWithObjects:
                   [UIColor yellowColor],
                   [UIColor orangeColor],
                   [UIColor redColor],
                   [UIColor magentaColor],
                   [UIColor purpleColor],
                   [UIColor blueColor],
                   [UIColor cyanColor],
                   [UIColor greenColor],
                   [UIColor grayColor],
                   nil];
    
    _chartView = [[MDRotatingPieChart alloc] initWithFrame:CGRectMake(10, 120, self.view.frame.size.width - 20, self.view.frame.size.height - 250)];
    
    _chartView.datasource = self;
    
    [self.view addSubview:_chartView];
}

- (NSInteger)numberOfSlices {
    return _chartData.count;
}

- (UIColor *)colorForSliceAtIndex:(NSInteger)index {
    return _chartColor[index % _chartColor.count];
}

- (CGFloat)valueForSliceAtIndex:(NSInteger)index {
    NSDictionary *chart = (NSDictionary*) _chartData[index];
    CGFloat fValue = [[chart valueForKey: @"amount"] floatValue];
    return fValue;
}

- (NSString *)labelForSliceAtIndex:(NSInteger)index {
    NSDictionary *chart = (NSDictionary*) _chartData[index];
    NSString *label = [NSString stringWithFormat:@"%@\n%@ %.2f",
                       [chart valueForKey:@"categoryName"],
                       currency,
                       [[chart valueForKey:@"amount"] floatValue]];
    return label;
}


#pragma mark- Data

- (void) getUserCurrency {
    currency = [[RMDataManagement getSharedInstance] getCurrentUserCurrencySymbol];
}

- (void) detectUpdateCurrency:(NSNotification*) notification {
    if (notification.object != nil) {
        Currency *currencyObject = (Currency *) notification.object;
        currency = currencyObject.symbol;
    }
}

- (void) getTransactionByTimePeriod:(NSString*) timePeriod {
    NSString *fromDate, *toDate;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *today = [NSDate new];
    
    if ([timePeriod isEqualToString: pickerData[0]]) { // today
        formatter.dateFormat = DATE_FORMATTER_IN_DB;
        fromDate = [formatter stringFromDate:today];
        toDate = fromDate;
        
    } else {
        NSDate *date;
        
        if ([timePeriod isEqualToString:pickerData[1]]) { // this week: from Monday to Sunday
            formatter.dateFormat = @"c";
            int dayOfWeek = [[formatter stringFromDate:today] intValue];// 7 for Saturday
            
            formatter.dateFormat = DATE_FORMATTER_IN_DB;
            // from date
            NSTimeInterval timeInterval = -1 * (60 * 60 * 24) * (dayOfWeek == 1 ? 7 : (dayOfWeek - 2));
            date = [today dateByAddingTimeInterval:timeInterval];
            fromDate = [formatter stringFromDate:date];
            
            // to date
            timeInterval = 60 * 60 * 24 * 6; // 7 days include [from date]
            date = [date dateByAddingTimeInterval:timeInterval];
            toDate = [formatter stringFromDate:date];
            
        } else if ([timePeriod isEqualToString:pickerData[2]]) { // this month
            formatter.dateFormat = @"YYYY-MM";
            NSString *temp = [formatter stringFromDate:today];
            
            fromDate = [NSString stringWithFormat:@"%@-01", temp];
            toDate = [NSString stringWithFormat:@"%@-31", temp];
            
        } else if ([timePeriod isEqualToString:pickerData[3]]) { // last month
            NSTimeInterval timeInterval = -1 * (60 * 60 * 24) * 30;
            today = [today dateByAddingTimeInterval:timeInterval];
            
            formatter.dateFormat = @"YYYY-MM";
            NSString *temp = [formatter stringFromDate:today];
            
            fromDate = [NSString stringWithFormat:@"%@-01", temp];
            toDate = [NSString stringWithFormat:@"%@-31", temp];
            
        } else if ([timePeriod isEqualToString:pickerData[4]]) { // this year
            formatter.dateFormat = @"YYYY";
            NSString *temp = [formatter stringFromDate:today];
            
            fromDate = [NSString stringWithFormat:@"%@-01-01", temp];
            toDate = [NSString stringWithFormat:@"%@-12-31", temp];
        }
    }
    
    [self getTransactionFromDate:fromDate toDate:toDate];
}

- (void) getTransactionFromDate:(NSString*) fromDate toDate:(NSString*) toDate {
    if (_chartView == nil) {
        [self initChart];
    } else {
        [_chartView reset];
    }
    
    NSArray *results = [[RMDataManagement getSharedInstance] reviewTransactionFromDate:fromDate toDate:toDate];
    if (results != nil) {
        [_expenseTransactions removeAllObjects];
        [_incomeTransactions removeAllObjects];
        
        for (NSDictionary *record in results) {
            if ([[record valueForKey:@"type"] intValue] == 0) {
                [_expenseTransactions addObject:record];
            } else {
                [_incomeTransactions addObject:record];
            }
        }
        
        if (self.transactionType.selectedSegmentIndex == 0) {
            _chartData = _expenseTransactions;
        } else {
            _chartData = _incomeTransactions;
        }
        
        if (_chartData.count > 0) {
            
            [_chartView setHidden:NO];
            [_noDataLabel setHidden:YES];
            
            [_chartView build];
            
        } else {
            [_chartView setHidden:YES];
            [_noDataLabel setHidden:NO];
        }
        
    } else {
        NSLog(@"CANNOT get Review Transaction data");
        [_chartView setHidden:YES];
        [_noDataLabel setHidden:NO];
    }
}

#pragma mark- PickerView

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return pickerData.count;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView titleForRow:(NSInteger)row {
    return pickerData[row];
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    _fromDate = nil;
    _toDate = nil;
    
    if ([pickerData[row] isEqualToString:@"Custome"]) {
        [self showCalendar];
        
    } else {
        [self.rangeButton setTitle:pickerData[row] forState:UIControlStateNormal];
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
    TTCalendar *calendar = [[TTCalendar alloc] init];
    calendar.delegate = self;
    [calendar show];
}

- (void)TTCalendarDidSelectWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate {
    _fromDate = fromDate;
    _toDate = toDate;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"dd MMM yyyy";
    
    [_rangeButton setTitle:[NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:_fromDate], [formatter stringFromDate:_toDate]]
                  forState:UIControlStateNormal];
    
    [formatter setDateFormat:DATE_FORMATTER_IN_DB];
    [self getTransactionFromDate:[formatter stringFromDate:_fromDate] toDate:[formatter stringFromDate:_toDate]];
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
    [_chartView reset];
    
    if (sender.selectedSegmentIndex == 0) {
        _chartData = _expenseTransactions;
    } else {
        _chartData = _incomeTransactions;
    }
    
    if (_chartData.count > 0) {
        
        [_chartView setHidden:NO];
        [_noDataLabel setHidden:YES];
        
        [_chartView build];
        
    } else {
        [_chartView setHidden:YES];
        [_noDataLabel setHidden:NO];
    }
}

#pragma mark- Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"transactionSegue"]) {
        RMTransactionController *vc = (RMTransactionController*) [segue destinationViewController];
        vc.currency = currency;
    }
}

@end

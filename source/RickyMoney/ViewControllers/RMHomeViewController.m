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
#import "RMParseRequestHandler.h"
#import "RMTransactionController.h"

#import "RickyMoney-Swift.h"

#import "RMDataManagement.h"

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    NSArray *cellData = _menuItems[indexPath.row];
    
    UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
    [icon setContentMode:UIViewContentModeCenter];
    [icon setImage: [UIImage imageWithIcon:cellData[0] backgroundColor:[UIColor clearColor] iconColor: RM_COLOR andSize:CGSizeMake(65, 40)]];
    
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
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        UIViewController *category = [mainStoryboard instantiateViewControllerWithIdentifier: @"OptionsVC"];
        [self.navigationController pushViewController: category animated: YES];
        
    } else if (indexPath.row == 3) { // about
        
        
    } else if (indexPath.row == 4) { // sign out
        [PFUser logOut];
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logoutSuccess];
        
    }
}

#pragma mark- Chart
- (void) initChart {
    
    _chartColor = [[NSArray alloc] initWithObjects:
                   [UIColor redColor],
                   [UIColor orangeColor],
                   RM_COLOR,
                   [UIColor yellowColor],
                   [UIColor colorWithRed:135.0/255.0 green:245.0/255.0 blue:150.0/255.0 alpha:1.0f],
                   [UIColor colorWithRed:5.0/255.0 green:185.0/255.0 blue:245.0/255.0 alpha:1.0f],
                   [UIColor colorWithRed:245.0/255.0 green:100.0/255.0 blue:225.0/255.0 alpha:1.0f],
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
    return _chartColor[index % 7];
}

- (CGFloat)valueForSliceAtIndex:(NSInteger)index {
    NSDictionary *chart = (NSDictionary*) _chartData[index];
    CGFloat fValue = [[chart valueForKey: @"value"] doubleValue];
    return fValue;
}

- (NSString *)labelForSliceAtIndex:(NSInteger)index {
    NSDictionary *chart = (NSDictionary*) _chartData[index];
    NSString *label = [NSString stringWithFormat:@"%@\n%@ %.2f",
                       [chart valueForKey:@"name"],
                       currency,
                       [[chart valueForKey:@"value"] floatValue]];
    return label;
}


#pragma mark- Data

- (void) getUserCurrency {
    [RMParseRequestHandler getCurrentUserInformation:^(PFObject* user) {
        PFObject *obj = [user objectForKey:@"currencyUnit"];
        if (obj != nil) {
            currency = obj[@"symbol"];
        }
    }];
}

- (void) detectUpdateCurrency:(NSNotification*) notification {
    if (notification.object != nil) {
        PFObject *currencyObject = (PFObject*) notification.object;
        currency = [currencyObject valueForKey:@"symbol"];
    }
}

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
    if (_chartView == nil) {
        [self initChart];
    } else {
        [_chartView reset];
    }
    // format of date is MM/dd/yyyy
    
    NSArray *objs = [[NSArray alloc] initWithObjects:[PFUser currentUser].objectId, @"ENName", fromDate, toDate, nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"userId", @"language", @"fromDate", @"toDate", nil];
    NSDictionary *params = [[NSDictionary alloc] initWithObjects: objs forKeys: keys];
    
    [RMParseRequestHandler callFunction:@"transactionReview" WithParams:params withSuccessBlock:^(NSDictionary *trans) {
        [_expenseTransactions removeAllObjects];
        
        NSDictionary *expense = [trans valueForKey:@"expense"];
        for (NSString *categoryId in [expense allKeys]) {
            NSDictionary *tran = [expense valueForKey:categoryId];
            NSDictionary *chart = @{
                                    @"name": [tran valueForKey:@"name"],
                                    @"value": [tran valueForKey:@"amount"]
                                    };
            [_expenseTransactions addObject:chart];
        }
        
        [_incomeTransactions removeAllObjects];
        NSDictionary *income = [trans valueForKey:@"income"];
        for (NSString *categoryId in [income allKeys]) {
            NSDictionary *tran = [income valueForKey:categoryId];
            NSDictionary *chart = @{
                                    @"name": [tran valueForKey:@"name"],
                                    @"value": [tran valueForKey:@"amount"]
                                    };
            [_incomeTransactions addObject:chart];
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
        
    }];
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
    RMCalendar *calendar = [[RMCalendar alloc] initCalendarWithTitle:@"... => ..." andConfirmButton:@"Next"];
    calendar.delegate = self;
    [calendar show];
}

- (void)RMCalendar:(RMCalendar *)calendar didSelectDate:(NSDate *)selectedDate {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    
    if (_fromDate == nil) {
        calendar.titleView.text = [NSString stringWithFormat:@"%@ => ...", [formatter stringFromDate:selectedDate]];
        [calendar.confirmButton setTitle:@"Confirm" forState:UIControlStateNormal];
        _fromDate = selectedDate;
        
    } else {
        _toDate = selectedDate;
        [calendar hide];
        
        [_rangeButton setTitle:[NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:_fromDate], [formatter stringFromDate:_toDate]]
                      forState:UIControlStateNormal];
        
        [formatter setDateFormat:@"dd MMM yyyy"];
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

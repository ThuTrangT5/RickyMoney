//
//  RMBudgetsViewController.m
//  RickyMoney
//
//  Created by Thu Trang on 4/10/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMBudgetsViewController.h"
#import "RMConstant.h"
#import "RMProgressCell.h"
#import "UIImage+FontAwesome.h"
//#import "RMObjects.h"
#import "RMDataManagement.h"

@implementation RMBudgetsViewController {
    NSArray *pickerData;
    NSDate *_fromDate, *_toDate;
    NSString *currency;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // insert calendar image for range button
    CGSize size = CGSizeMake(20, 20);
    UIImage *calendarImg = [UIImage imageWithIcon:@"fa-calendar" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] andSize:size];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [imgView setImage:calendarImg];
    [_rangeButton addSubview:imgView];
    
    _budgetData = [[NSMutableArray alloc] init];
    pickerData = [[NSArray alloc] initWithObjects:@"Today", @"This Week", @"This Month", @"Last Month", @"This Year", @"Custome", nil];
    
    [self getUserCurrency];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_fromDate == nil && _toDate == nil) {
        [self getBudgetsByTimePeriod: _rangeButton.titleLabel.text];
        
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = DATE_FORMATTER_IN_DB;
        NSString *fromDate = [formatter stringFromDate:_fromDate];
        NSString *toDate = [formatter stringFromDate:_toDate];
        
        [self getBudgetsFromDate:fromDate toDate:toDate];
    }
}
#pragma mark- Data

- (void) getUserCurrency {
    currency = [[RMDataManagement getSharedInstance] getCurrentUserCurrencySymbol];
}

- (void) getBudgetsFromDate:(NSString*) fromDate toDate:(NSString*) toDate {
    [_budgetData removeAllObjects];
    NSArray *budgets = [[RMDataManagement getSharedInstance] getAllBudgetsFromDate:fromDate toDate:toDate];
    if (budgets != nil) {
        [_budgetData addObjectsFromArray:budgets];
    }
    [self.tableView reloadData];
}

- (void) getBudgetsByTimePeriod:(NSString*) timePeriod {
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
    
    [self getBudgetsFromDate:fromDate toDate:toDate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _budgetData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RMProgressCell *cell = (RMProgressCell*)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *cellData = (NSDictionary*) [_budgetData objectAtIndex:indexPath.row];
    NSString *budgetValue = [NSString stringWithFormat:@"%@ %.2f", currency, [[cellData valueForKey:@"budget"] floatValue]];
    
    [cell setProgressValue:[[cellData valueForKey:@"expense"] floatValue] maxValue:[[cellData valueForKey:@"budget"] floatValue]];
    [cell setCurrencySymbol:currency];
    [cell setCategoryName:[cellData valueForKey:@"categoryName"]];
    [cell setBudgetValue: budgetValue];
    
    return cell;
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
        [self getBudgetsByTimePeriod:pickerData[row]];
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
    TTCalendar *calendar = [[TTCalendar alloc]init];
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
    [self getBudgetsFromDate:[formatter stringFromDate:_fromDate] toDate:[formatter stringFromDate:_toDate]];
}

#pragma mark- Actions

- (IBAction)ontouchSelectRange:(id)sender {
    [self showPicker];
}
@end

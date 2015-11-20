//
//  RMHomeViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/5/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMHomeViewController.h"
#import "UIImage+FontAwesome.h"
#import "RMConstant.h"
#import "AppDelegate.h"
#import "UIColor+HexColor.h"
#import "RMParseRequestHandler.h"

@implementation RMHomeViewController

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
    _timePeriod = MONTHLY;
    
    // chart
    [self initChart];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self getTransactionByUser];
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
    [icon setImage: [UIImage imageWithIcon:cellData[0] backgroundColor:[UIColor clearColor] iconColor: RM_COLOR andSize:CGSizeMake(20, 20)]];
    
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
    [_chartView setHoleRadiusPrecent:0.3];
    
    [_chartView setLabelsPosition:VBLabelsPositionOutChart];
    
}

- (void) getTransactionByUser {
    NSString *from, *to;
    
//    NSDate *today = [NSDate date];
    NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
    int day, month, year;
    
    [myFormatter setDateFormat:@"dd/MM/yyy"];
    NSDate *today = [myFormatter dateFromString:@"27/12/2015"];
    
    [myFormatter setDateFormat:@"dd"];
    day = [[myFormatter stringFromDate:today] intValue];
    [myFormatter setDateFormat:@"MM"];
    month = [[myFormatter stringFromDate:today] intValue];
    [myFormatter setDateFormat:@"yyyy"];
    year = [[myFormatter stringFromDate:today] intValue];
    
    _timePeriod = WEEKLY;
    // date string format mm/dd/yyyy
    switch (_timePeriod) {
        case WEEKLY:
            // weekly from sunday to saturday
            [myFormatter setDateFormat:@"c"];
            int dayOfWeek = [[myFormatter stringFromDate:today] intValue]; // 7 for Saturday
            
            
            // from date
            if (day - dayOfWeek >= 0) {
                from = [NSString stringWithFormat:@"%d/%d/%d",month, (day - dayOfWeek) + 1, year];
                
            } else {
                if (month == 1 || month== 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12){
                    if (month == 1) {
                        from = [NSString stringWithFormat:@"11/%d/%d",  31 + (day - dayOfWeek), year - 1];
                    } else {
                        from = [NSString stringWithFormat:@"%d/%d/%d", month - 1, 31 + (day - dayOfWeek), year];
                    }
                } else if (month == 2) {
                    if (year % 4 == 0) { // leap year
                        from = [NSString stringWithFormat:@"11/%d/%d",  29 + (day - dayOfWeek), year];
                    } else {
                        from = [NSString stringWithFormat:@"11/%d/%d",  28 + (day - dayOfWeek), year];
                    }
                } else {
                    from = [NSString stringWithFormat:@"11/%d/%d",  30 + (day - dayOfWeek), year];
                }
            }
            
            // to date
            if (day + (7- dayOfWeek) > 31) {
                if (month == 1 || month== 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12){
                    if (month == 12) {
                        to = [NSString stringWithFormat:@"01/%d/%d", (day + (7- dayOfWeek) - 31), year + 1];
                    } else {
                        to = [NSString stringWithFormat:@"01/%d/%d", (day + (7- dayOfWeek) - 31), year ];
                    }
                } else if (month == 2) {
                    if (year % 4 == 0) { // leap year
                        to = [NSString stringWithFormat:@"03/%d/%d", (day + (7- dayOfWeek) - 29), year ];
                    } else {
                        to = [NSString stringWithFormat:@"03/%d/%d", (day + (7- dayOfWeek) - 28), year ];
                    }
                } else {
                    to = [NSString stringWithFormat:@"%d/%d/%d", month + 1, (day + (7- dayOfWeek) - 30), year ];
                }
                
            } else {
                to = [NSString stringWithFormat:@"%d/%d/%d", month, (day + (7- dayOfWeek) - 31), year ];
            }
            
            break;
            
        case MONTHLY:
            
            from = [NSString stringWithFormat:@"%d/01/%d",month,year];
            if (month == 12) {
                to = [NSString stringWithFormat:@"01/01/%d", year + 1];
            } else {
                to = [NSString stringWithFormat:@"%d/01/%d", month + 1, year];
            }
            
            break;
            
        case YEARLY:
            from = [NSString stringWithFormat:@"01/01/%d",year];
            to = [NSString stringWithFormat:@"01/01/%d",year + 1];
            break;
            
        default:
            break;
    }
    
    
    
    NSArray *objs = [[NSArray alloc] initWithObjects:[PFUser currentUser].objectId, @"ENName", from, to, nil];
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

#pragma mark- Actions

- (IBAction)ontouchMenu:(id)sender {
    [self.menuTableView reloadData];
    [self showDropDownView];
}

- (IBAction)ontouchSelectRange:(UIButton *)sender {
}

- (IBAction)onchangeTransactionType:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        [_chartView setChartValues:_expenseTransactions animation:YES];
        
    } else if (sender.selectedSegmentIndex == 1) {
        [_chartView setChartValues:_incomeTransactions animation:YES];
    }
}
@end

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
    
    // UI for menu bar button
    UIImage *menuicon = [UIImage imageWithIcon:@"fa-list-ul" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] andSize:CGSizeMake(25, 25)];
    [self.navigationItem.leftBarButtonItem setImage:menuicon];
    [self.navigationItem.leftBarButtonItem setTitle:@""];
    
//    [self initChart];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    [self getTransactionByUser];
//}

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
        frame.size.height = 52 * (_menuItems.count);
        [self.menuTableView setFrame:frame];
        [self.menuTableView setHidden:NO];
    }
    
    // Show/hide dropdown view
    if ([self.dropdownView isOpen]) {
        [self.dropdownView hide];
    }
    else {
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
        [self.view addSubview:_chartView];
    }
    [_chartView setFrame:CGRectMake((self.view.bounds.size.width - 300)/2, 90, 300, 300)];
    
    [_chartView setHoleRadiusPrecent:0.3]; /* hole inside of chart */
    [_chartView setEnableStrokeColor:YES];
    [_chartView setHoleRadiusPrecent:0.3];
    
    [_chartView.layer setShadowOffset:CGSizeMake(2, 2)];
    [_chartView.layer setShadowRadius:3];
    [_chartView.layer setShadowColor:[UIColor blackColor].CGColor];
    [_chartView.layer setShadowOpacity:0.7];
    
    [_chartView setLabelsPosition:VBLabelsPositionOnChart];
    
//    NSArray *chartValues = @[
//                             @{@"name":@"Food", @"value":@50, @"color":[UIColor colorWithHex:0xdd191daa]},
//                             @{@"name":@"Eletric & Water", @"value":@20, @"color":[UIColor colorWithHex:0xd81b60aa]},
//                             @{@"name":@"Friends", @"value":@40, @"color":[UIColor colorWithHex:0x8e24aaaa]},
//                             @{@"name":@"Eating & Drinking", @"value":@70, @"color":[UIColor colorWithHex:0x3f51b5aa]},
//                             @{@"name":@"Gas", @"value":@65, @"color":[UIColor colorWithHex:0x5677fcaa]},
//                             @{@"name":@"Internet", @"value":@23, @"color":[UIColor colorWithHex:0x2baf2baa]},
//                             @{@"name":@"Transportation", @"value":@34, @"color":[UIColor colorWithHex:0xb0bec5aa]},
//                             @{@"name":@"Study", @"value":@54, @"color":[UIColor colorWithHex:0xf57c00aa]}
//                             ];
    
}

- (void) getTransactionByUser {
    NSArray *objs = [[NSArray alloc] initWithObjects:[PFUser currentUser].objectId, @"Monthly", @"ENName", nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"userId", @"timePeriod", @"language", nil];
    NSDictionary *params = [[NSDictionary alloc] initWithObjects: objs forKeys: keys];
    
    [RMParseRequestHandler callFunction:@"transactionReview" WithParams:params withSuccessBlock:^(NSDictionary *trans) {
        NSMutableArray *chartValues = [[NSMutableArray alloc] init];
    
        NSDictionary *expense = [trans valueForKey:@"expense"];
        for (NSString *categoryId in [expense allKeys]) {
            NSDictionary *tran = [expense valueForKey:categoryId];
            NSDictionary *chart = @{
                                    @"name": [tran valueForKey:@"name"],
                                    @"value": [tran valueForKey:@"amount"],
                                    @"color": [UIColor purpleColor]
                                    };
            [chartValues addObject:chart];
        }
        
        NSDictionary *income = [trans valueForKey:@"income"];
        for (NSString *categoryId in [income allKeys]) {
            NSDictionary *tran = [income valueForKey:categoryId];
            NSDictionary *chart = @{
                                    @"name": [tran valueForKey:@"name"],
                                    @"value": [tran valueForKey:@"amount"],
                                    @"color": [UIColor greenColor]
                                    };
            [chartValues addObject:chart];
        }
        
         [_chartView setChartValues:chartValues animation:YES];
    }];
    //transactionReview
    
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
@end

//
//  RMTransactionController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/10/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMTransactionController.h"
#import "RMTransactionDetailController.h"

#import "RMDataManagement.h"
#import "RMObjects.h"
#import "MDTableViewCell.h"

#define DATE_FORMAT_STRING @"EEE, MMM dd yyyy"

@implementation RMTransactionController {
    NSIndexPath *selectedIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _transactions = [[NSMutableArray alloc] init];
    currentPage = 0;
    
    // hide separator for empty row
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectInsertNewTransaction:) name:kInsertNewTransaction object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectUpdateTransaction:) name:kUpdateTransaction object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (currentPage == 0) {
        if (_currency == nil || _currency.length == 0) {
            _currency = @"";
            [self getUserCurrency];
            
        } else {
            [_transactions removeAllObjects];
            [self getTransactionsByPage:1];
        }
    }
}

#pragma mark- Data
- (void) getUserCurrency {
    _currency = [[RMDataManagement getSharedInstance] getCurrentUserCurrencySymbol];
    
    [_transactions removeAllObjects];
    [self getTransactionsByPage:1];
}

- (void) getTransactionsByPage:(int) page {
    if (page == 1) {
        [_transactions removeAllObjects];
    }
    
    NSArray *objects = [[RMDataManagement getSharedInstance] getTransactionsByPage:page category:_categoryId type:_transactionType];
    if (objects != nil) {
        currentPage = page;
        [_transactions addObjectsFromArray:objects];
        [self.tableView reloadData];
    }
}

- (void) detectInsertNewTransaction:(NSNotification*) notification {
    if (notification.object != nil) {
        Transaction *newTransaction = (Transaction*) notification.object;
        [_transactions insertObject:newTransaction atIndex:0];
        NSIndexPath *idp = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[idp] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) detectUpdateTransaction:(NSNotification*) notification {
    if (notification.object != nil) {
        _transactions[selectedIndexPath.row] = (Transaction*) notification.object;
        [self.tableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }
}

#pragma mark- TableView delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"transactionCell"];
    
    // UI
    UIView *amountView = [cell viewWithTag:1];
    amountView.layer.cornerRadius = 20.0f;
    amountView.layer.masksToBounds = YES;
    amountView.layer.borderWidth = 2.0f;
    amountView.layer.borderColor = RM_COLOR.CGColor;
    
    // Data
    Transaction *cellData = _transactions[indexPath.row];
    NSString *item = cellData.item;
    NSString *amount = [NSString stringWithFormat:@"%@ %.2f",_currency, cellData.amount];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = DATE_FORMAT_STRING;
    NSString *mdy = [formatter stringFromDate: cellData.date];
    
    [(UILabel*) [cell viewWithTag:1] setText:amount];
    [(UILabel*) [cell viewWithTag:2] setText:item];
    [(UILabel*) [cell viewWithTag:3] setText:mdy];
    
    if (indexPath.row == _transactions.count - 1 && _transactions.count >= ITEMS_PER_PAGE *currentPage) {
        [self getTransactionsByPage:currentPage + 1];
    }
    
    cell.rippleColor = RM_COLOR;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    double delayInSeconds = 0.35;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        selectedIndexPath = indexPath;
        NSString *transactionId = [(Transaction*)_transactions[indexPath.row] objectId];
        [self performSegueWithIdentifier:@"transactionDetail" sender:transactionId];
    });
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Transaction *obj = _transactions[indexPath.row];
        
        if ([[RMDataManagement getSharedInstance] deleteTransaction:obj.objectId] == YES) {
            [_transactions removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        } else {
            //???
        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark- Prepare for Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"transactionDetail"]) {
        RMTransactionDetailController *detailVC = (RMTransactionDetailController*) segue.destinationViewController;
        
        if ([sender isKindOfClass:[UIBarButtonItem class]]) { // touch on Insert new Transaction bar button
            detailVC.transactionType = _transactionType;
            
        } else {
            NSString *transactionId = (NSString*) sender;
            detailVC.transactionId = transactionId;
        }
    }
}

#pragma mark- Actions

- (IBAction)onchangeTransactionType:(UISegmentedControl *)sender {
    _transactionType = (sender.selectedSegmentIndex == 0) ? EXPENSE : INCOME;
    
    [_transactions removeAllObjects];
    [self.tableView reloadData];
    
    [self getTransactionsByPage:1];
}
@end

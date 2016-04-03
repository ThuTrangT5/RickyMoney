//
//  RMTransactionController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/10/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMTransactionController.h"
#import <Parse/Parse.h>
#import "RMParseRequestHandler.h"
#import "RMTransactionDetailController.h"

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
    [RMParseRequestHandler getCurrentUserInformation:^(PFObject* user) {
        PFObject *obj = [user objectForKey:@"currencyUnit"];
        if (obj != nil) {
            _currency = obj[@"symbol"];
        }
        
        [_transactions removeAllObjects];
        [self getTransactionsByPage:1];
    }];
}

- (void) getTransactionsByPage:(int) page {
    if (page == 1) {
        [_transactions removeAllObjects];
    }
    
    [RMParseRequestHandler getAllTransactionByUser:[PFUser currentUser].objectId
                                   transactionType:_transactionType
                                        inCategory:_categoryId
                                           forPage: page
                                  withSuccessBlock:^(NSArray *objects) {
                                      currentPage = page;
                                      [_transactions addObjectsFromArray:objects];
                                      [self.tableView reloadData];
                                  }];
}

- (void) detectInsertNewTransaction:(NSNotification*) notification {
    if (notification.object != nil) {
        PFObject *newTransaction = (PFObject*) notification.object;
        [_transactions insertObject:newTransaction atIndex:0];
        NSIndexPath *idp = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[idp] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void) detectUpdateTransaction:(NSNotification*) notification {
    if (notification.object != nil) {
        _transactions[selectedIndexPath.row] = (PFObject*) notification.object;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"transactionCell"];
    
    // UI
    UIView *amountView = [cell viewWithTag:1];
    amountView.layer.cornerRadius = 20.0f;
    amountView.layer.masksToBounds = YES;
    amountView.layer.borderWidth = 2.0f;
    amountView.layer.borderColor = RM_COLOR.CGColor;
    
    // Data
    PFObject *cellData = _transactions[indexPath.row];
    NSString *item = [cellData valueForKey:@"itemName"];
    NSString *amount = [NSString stringWithFormat:@"%@ %@",_currency, [cellData valueForKey:@"amount"]];
    NSDate *date = [cellData valueForKey:@"transactionDate"];
    if (date == nil) {
        date = [NSDate new];
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE, MMM dd yyyy";
    NSString *mdy = [formatter stringFromDate:date];
    
    [(UILabel*) [cell viewWithTag:1] setText:amount];
    [(UILabel*) [cell viewWithTag:2] setText:item];
    [(UILabel*) [cell viewWithTag:3] setText:mdy];
    
    if (indexPath.row == _transactions.count - 1 && _transactions.count >= ITEM_PER_PAGE *currentPage) {
        [self getTransactionsByPage:currentPage+1];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndexPath = indexPath;
    NSString *transactionId = [(PFObject*)_transactions[indexPath.row] objectId];
    [self performSegueWithIdentifier:@"transactionDetail" sender:transactionId];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *obj = _transactions[indexPath.row];
        [_transactions removeObjectAtIndex:indexPath.row];
        NSLog(@"DELETE => %@", obj.objectId);
        
        [obj deleteEventually];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
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

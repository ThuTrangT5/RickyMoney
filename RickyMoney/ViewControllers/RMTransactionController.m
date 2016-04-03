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
    NSDateFormatter *_formatter;
    NSIndexPath *selectedIndexPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _transactions = [[NSMutableArray alloc] init];
    currentPage = 0;
    
    
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"EEEE, dd MMMM yyyy"];
    
    // notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectInsertNewTransaction:) name:kInsertNewTransaction object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectUpdateTransaction:) name:kUpdateTransaction object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (currentPage == 0) {
        [_transactions removeAllObjects];
        [self getTransactionsByPage:1];
    }
}

#pragma mark- Data

- (void) getTransactionsByPage:(int) page {
    if (page == 1) {
        [_transactions removeAllObjects];
    }
    
    [RMParseRequestHandler getAllTransactionByUser:[PFUser currentUser].objectId
                                   transactionType:_transactionType
                                        inCategory:_category
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
    PFObject *cellData = _transactions[indexPath.row];
    NSString *item = [cellData valueForKey:@"itemName"];
    NSString *amount = [NSString stringWithFormat:@"%@",[cellData valueForKey:@"amount"]];
    
    NSString *date = @"";
    if ([cellData valueForKey:@"transactionDate"] != nil) {
        date = [_formatter stringFromDate: [cellData valueForKey:@"transactionDate"]];
    }
    
    [(UILabel*) [cell viewWithTag:1] setText:item];
    [(UILabel*) [cell viewWithTag:2] setText:amount];
    [(UILabel*) [cell viewWithTag:3] setText:date];
    
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

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

@implementation RMTransactionController

#define TRANSACTION_PER_PAGE 15

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _transactions = [[NSMutableArray alloc] init];
    [self getTransactionsByPage:1];
}

- (void) getTransactionsByPage:(int) page {
    PFQuery *query = [PFQuery queryWithClassName:@"Transaction"];
    [query whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [query orderByDescending:@"transactionDate"];
    [query setLimit:TRANSACTION_PER_PAGE];
    [query setSkip:TRANSACTION_PER_PAGE * (page - 1)];
    
    [RMParseRequestHandler getDataByQuery:query withSuccessBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
        currentPage = page;
        [_transactions addObjectsFromArray:objects];
        [self.tableView reloadData];
    }];
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
    NSString *date = [NSString stringWithFormat:@"%@",[cellData valueForKey:@"transactionDate"]];
    date = [date substringToIndex:19];
    
    [(UILabel*) [cell viewWithTag:1] setText:item];
    [(UILabel*) [cell viewWithTag:2] setText:amount];
    [(UILabel*) [cell viewWithTag:3] setText:date];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *transactionId = [(PFObject*)_transactions[indexPath.row] objectId];
    [self performSegueWithIdentifier:@"transactionDetail" sender:transactionId];
}

#pragma mark- Prepare for Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"transactionDetail"]) {
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            return;
        }
        NSString *transactionId = (NSString*) sender;
        RMTransactionDetailController *detailVC = (RMTransactionDetailController*) segue.destinationViewController;
        [detailVC setTransactionId:transactionId];
    }
}
@end

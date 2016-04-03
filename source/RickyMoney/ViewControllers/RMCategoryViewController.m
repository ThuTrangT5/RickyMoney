//
//  RMCategoryViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/6/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMCategoryViewController.h"
#import <Parse/PFQuery.h>
#import <Parse/PFFile.h>
#import "RMParseRequestHandler.h"
#import "RMTransactionController.h"

@implementation RMCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getAllCategories];
}

- (void) getAllCategories {
    PFQuery *query = [PFQuery queryWithClassName:@"Category"];
    [query orderByAscending:@"ENName"];
    [RMParseRequestHandler getDataByQuery:query withSuccessBlock:^(NSArray * objects) {
        _categories = objects;
        [self.tableView reloadData];
    }];
}

#pragma mark- TableView datasource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
    PFObject *cellData = [_categories objectAtIndex:indexPath.row];
    
    // icon
    PFFile *imageFile = [cellData objectForKey:@"icon"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
            [icon setImage:[UIImage imageWithData:data]];
        }
    }];
    
    // category name
    UILabel *name = (UILabel*)[cell viewWithTag:2];
    [name setText:[cellData valueForKey:@"ENName"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *cellData = [_categories objectAtIndex:indexPath.row];
    NSString *categoryId = cellData.objectId;
    [self performSegueWithIdentifier:@"transactionSegue" sender:categoryId];
}

#pragma mark- prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"transactionSegue"]) {
        RMTransactionController *vc = (RMTransactionController*) segue.destinationViewController;
        vc.categoryId = (NSString*) sender;
    }
}
@end

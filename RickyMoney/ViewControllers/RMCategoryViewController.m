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

@implementation RMCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getAllCategories];
}

- (void) getAllCategories {
    PFQuery *query = [PFQuery queryWithClassName:@"Category"];
    [query orderByAscending:@"ENName"];
    [RMParseRequestHandler getDataByQuery:query withSuccessBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
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
@end

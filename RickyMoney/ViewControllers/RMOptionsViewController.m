//
//  RMOptionsViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/7/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMOptionsViewController.h"
#import "RMParseRequestHandler.h"
#import <Parse/PFFile.h>

@implementation RMOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (_option) {
        case OPTION_PASSCODE:
            break;
            
        case OPTION_CURRENCY:
            [self getCurrencyUnit];
            break;
            
        case OPTION_CATEGORY:
            [self getCategory];
            break;
        default:
            break;
    }
}

- (void) getCurrencyUnit {
    [RMParseRequestHandler getAllCurrencyUnitsWithSuccessBlock:^(NSArray * objects) {
        _optionData = objects;
        [self.tableView reloadData];
    }];
}

- (void) getCategory {
    PFQuery *query = [PFQuery queryWithClassName:@"Category"];
    [RMParseRequestHandler getDataByQuery:query withSuccessBlock:^(NSArray * objects) {
        _optionData = objects;
        [self.tableView reloadData];
    }];
}

#pragma mark- TableView delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int row = 0;
    
    switch (_option) {
        case OPTION_PASSCODE:
            row = 2;
            break;
            
        default:
            row = (int)_optionData.count;
            break;
    }
    
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = cell;
    
    switch (_option) {
        case OPTION_CURRENCY:{
            cell = [tableView dequeueReusableCellWithIdentifier:@"currencyCell"];
            [cell.textLabel setText: [_optionData[indexPath.row] valueForKey:@"name"]];
            [cell.detailTextLabel setText: [_optionData[indexPath.row] valueForKey:@"symbol"]];
        }
            break;
            
        case OPTION_PASSCODE:{
            NSString *identifier = [NSString stringWithFormat:@"passcodeCell%d", (int) indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        }
            break;
            
        case OPTION_CATEGORY: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
            
            // icon
            PFFile *imageFile = [_optionData[indexPath.row] objectForKey:@"icon"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
                    [icon setImage:[UIImage imageWithData:data]];
                }
            }];
            
            // name
            UILabel *categoryName = (UILabel*) [cell viewWithTag:2];
            [categoryName setText:[_optionData[indexPath.row] valueForKey:@"ENName"]];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (_option) {
        case OPTION_CATEGORY:{
            if (self.delegate != nil) {
                NSMutableDictionary *selectedData = [[NSMutableDictionary alloc] init];
                PFObject *cellData = _optionData[indexPath.row];
                [selectedData setValue:cellData.objectId forKey:@"objectId"];
                [selectedData setValue:cellData[@"ENName"] forKey:@"categoryName"];
                
                [self.delegate optionView:_option DoneWithSelectedData:selectedData];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
            break;
            
        case OPTION_CURRENCY: {
            PFObject *cellData = _optionData[indexPath.row];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCurrency object:cellData[@"symbol"]];
            [RMParseRequestHandler updateCurrencyUnit:cellData.objectId bllock:^(BOOL succeed, NSError *error) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        }
            break;
            
        case OPTION_PASSCODE:
            break;
            
        default:
            break;
    }
    
}

- (IBAction)ontouchSaveButton:(id)sender {
}
@end

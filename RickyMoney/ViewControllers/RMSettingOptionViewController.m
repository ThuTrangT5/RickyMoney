//
//  RMSettingOptionViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/7/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMSettingOptionViewController.h"
#import <Parse/PFQuery.h>
#import "RMParseRequestHandler.h"

@implementation RMSettingOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (_option) {
        case OPTION_PASSCODE:
            break;
            
        case OPTION_CURRENCY:
            [self getCerrencyUnit];
            break;
            
        case OPTION_REPORT:{
            _optionData = REPORT_OPTIONS;
            [self.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
}

- (void) getCerrencyUnit {
    PFQuery *query = [PFQuery queryWithClassName:@"CurrencyUnit"];
    [RMParseRequestHandler getDataByQuery:query withSuccessBlock:^(NSArray * __nullable objects, NSError * __nullable error) {
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
            
        case OPTION_REPORT:{
            cell = [tableView dequeueReusableCellWithIdentifier:@"reportCell"];
            [cell.textLabel setText: _optionData[indexPath.row]];
        }
            break;
            
        case OPTION_PASSCODE:{
            NSString *identifier = [NSString stringWithFormat:@"passcodeCell%d", (int) indexPath.row];
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *optionId = nil;
        NSString *name = cell.textLabel.text;
        
        if (_option == OPTION_CURRENCY) {
            optionId = [_optionData[indexPath.row] valueForKey:@"objectId"];
            name = [NSString stringWithFormat:@"%@ (%@)", cell.textLabel.text, cell.detailTextLabel.text];
        }
        [self.delegate settingOption:self.option DidSelectedWithName:name andOptionId:optionId];
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}

@end

//
//  RMSettingViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/7/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMSettingViewController.h"
#import "RMConstant.h"

@implementation RMSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark- Tableview delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [NSString stringWithFormat:@"settingCell%ld", (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"optionSegue" sender:indexPath];
}

#pragma mark- RMSettingOptionDelegate

- (void)settingOption:(SettingOptions)settingOption DidSelectedWithName:(NSString *)optionName andOptionId:(NSString *)optionId {
    int row = 0;
    if (settingOption == OPTION_CURRENCY) {
        row = 1;
    } else if (settingOption == OPTION_REPORT) {
        row = 2;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.detailTextLabel setText:optionName];
    
}

#pragma mark- prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"optionSegue"]) {
        RMSettingOptionViewController *optionVC = (RMSettingOptionViewController*)[segue destinationViewController];
        optionVC.delegate = self;
        NSIndexPath *idp = (NSIndexPath*) sender;
        if (idp.row == 0) {
            optionVC.option = OPTION_PASSCODE;
        } else if (idp.row == 1) {
            optionVC.option = OPTION_CURRENCY;
        } else {
            optionVC.option = OPTION_REPORT;
        }
    }
}

@end

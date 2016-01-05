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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 150;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
        
        UIImageView *profile = (UIImageView*)[cell viewWithTag:1];
        profile.layer.cornerRadius = profile.frame.size.width;
        profile.layer.masksToBounds = YES;
        
    } else {
        NSString *identifier = [NSString stringWithFormat:@"settingCell%ld", (long)indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"passcodeSegue" sender:nil];
            
        } else if (indexPath.row == 1){
            [self performSegueWithIdentifier:@"optionSegue" sender:indexPath];
        }
    }
}

#pragma mark- RMOptionsDelegate

- (void) optionView:(OptionTypes) option DoneWithSelectedData:(NSDictionary*) selectedData {
    
}

#pragma mark- prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"optionSegue"]) {
        RMOptionsViewController *optionVC = (RMOptionsViewController*)[segue destinationViewController];
        optionVC.delegate = self;
        optionVC.option = OPTION_CURRENCY;
    }
}

@end

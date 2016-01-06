//
//  RMSettingViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/7/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMSettingViewController.h"
#import "RMConstant.h"
#import "UIImage+FontAwesome.h"
#import "RMParseRequestHandler.h"
#import <Parse/PFObject.h>

@implementation RMSettingViewController {
    NSMutableArray *_userInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _userInfo = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getUserInfo];
}

#pragma mark- User information
- (void) getUserInfo {
    [RMParseRequestHandler getCurrentUserInformation:^(PFObject *user) {
        NSString *currency = [NSString stringWithFormat:@"%@ (%@)", [user objectForKey:@"currencyUnit"][@"name"], [user objectForKey:@"currencyUnit"][@"symbol"]];
        NSString *passcode = [[NSUserDefaults standardUserDefaults] valueForKey:kPasscode] == nil ? @"OFF" : @"ON";
        
        _userInfo[0] = @[@"fa-envelope-o",@"Email", user[@"username"]];
        _userInfo[1] = @[@"fa-money", @"Currency", currency];
        _userInfo[2] = @[@"fa-key", @"Passcode", passcode];
        //_userInfo[3] = @[@"fa-key", @"Wallet", passcode];
        // language ???
        
        [self.tableView reloadData];
    }];
}

#pragma mark- Tableview delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _userInfo.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 110;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"avatarCell"];
        
        //        UIImageView *profile = (UIImageView*)[cell viewWithTag:1];
        //        profile.layer.cornerRadius = profile.frame.size.width;
        //        profile.layer.masksToBounds = YES;
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell"];
        
        NSArray *cellData = _userInfo[indexPath.row];
        
        UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
        [icon setContentMode:UIViewContentModeCenter];
        [icon setImage: [UIImage imageWithIcon:cellData[0] backgroundColor:[UIColor clearColor] iconColor: RM_COLOR andSize:CGSizeMake(30, 25)]];
        
        [(UILabel*)[cell viewWithTag:2] setText:cellData[1]];
        [(UILabel*)[cell viewWithTag:3] setText:cellData[2]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"optionSegue" sender:indexPath];
            
        } else if (indexPath.row == 2){
            [self performSegueWithIdentifier:@"passcodeSegue" sender:nil];
        }
    }
}

#pragma mark- RMOptionsDelegate

- (void) optionView:(OptionTypes) option DoneWithSelectedData:(id) selectedData {
    switch (option) {
        case OPTION_CURRENCY: {
            PFObject *currency = [PFObject objectWithoutDataWithClassName:@"CurrencyUnit" objectId: (NSString*) selectedData];
            [[PFUser currentUser] setObject:currency forKey:@"currencyUnit"];
            [[PFUser currentUser] saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
                
                // reload user information
                [self getUserInfo];
            }];
        }
            break;
            
        case OPTION_PASSCODE:
            
            break;
        default:
            break;
    }
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

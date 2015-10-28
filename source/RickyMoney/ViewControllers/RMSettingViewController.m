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
    return 3;
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
    if (indexPath.row > 0) {
        [self performSegueWithIdentifier:@"optionSegue" sender:indexPath];
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
        NSIndexPath *idp = (NSIndexPath*) sender;
        if (idp.row == 0) {
            optionVC.option = OPTION_PASSCODE;
        } else if (idp.row == 1) {
            optionVC.option = OPTION_CURRENCY;
        } else if (idp.row == 2) {
            optionVC.option = OPTION_PERIOD_TIME;
        } 
    }
}

#pragma mark- Passcode

- (IBAction)turnOnOffPasscode:(id)sender {
    
    if ([((UISwitch*) sender) isOn]) {
        // open Passcode page
        
        THPinViewController *pinViewController = [[THPinViewController alloc] initWithDelegate:self];
        pinViewController.promptTitle = @"Enter Passcode";
        pinViewController.promptColor =  RM_COLOR;
        pinViewController.view.tintColor = RM_COLOR;
        pinViewController.hideLetters = YES;
        pinViewController.disableCancel = NO;
        
        // for a translucent background, use this:
        self.view.tag = THPinViewControllerContentViewTag;
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        pinViewController.translucentBackground = YES;
        
        [self presentViewController:pinViewController animated:YES completion:nil];
    }
}

// mandatory delegate methods

- (NSUInteger)pinLengthForPinViewController:(THPinViewController *)pinViewController
{
    return 5;
}

- (BOOL)pinViewController:(THPinViewController *)pinViewController isPinValid:(NSString *)pin
{
//    if ([pin isEqualToString:self.correctPin]) {
//        return YES;
//    } else {
//        self.remainingPinEntries--;
//        return NO;
//    }
    return YES;
}

- (BOOL)userCanRetryInPinViewController:(THPinViewController *)pinViewController
{
    return YES;
}

@end

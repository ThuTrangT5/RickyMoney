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

#import "RMObjects.h"
#import "RMDataManagement.h"

#import "RMChangePasswordViewController.h"
#import "MDTableViewCell.h"

@implementation RMSettingViewController {
    NSMutableArray *_userInfo;
    User *currentUser;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userInfo = [[NSMutableArray alloc] init];
    [self getUserInfo];
    
    _profileField.layer.cornerRadius = _profileField.frame.size.width / 2.0f;
    _profileField.layer.masksToBounds = YES;
    
}

//- (void)viewDidAppear:(BOOL)animated {
//    NSLog(@"Current Password = %@", currentUser.password);
//}

#pragma mark- User information
- (void) getUserInfo {
    
    currentUser = [[RMDataManagement getSharedInstance] getCurrentUserDetail];
    if (currentUser != nil) {
        NSString *currency = [NSString stringWithFormat:@"%@(%@)", currentUser.currencyName, currentUser.currencySymbol];
        
        _userInfo[0] = @[@"fa-envelope-o",@"Email", currentUser.email];
        _userInfo[1] = @[@"fa-money", @"Currency", currency];
        _userInfo[2] = @[@"fa-lock", @"Passcode", currentUser.passcode == nil ? @"OFF" : @"ON"];
        
        [self.tableView reloadData];
        
        if (currentUser.avatar != nil) {;
            UIImage *image = [RMDataManagement decodeBase64ToImage:currentUser.avatar];
            [_profileField setBackgroundImage:image forState:UIControlStateNormal];
        }
    }
}

#pragma mark- Tableview delegate & datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _userInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"cell";
    MDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSArray *cellData = _userInfo[indexPath.row];
    
    UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
    [icon setContentMode:UIViewContentModeCenter];
    [icon setImage: [UIImage imageWithIcon:cellData[0] backgroundColor:[UIColor clearColor] iconColor: RM_COLOR andSize:CGSizeMake(30, 25)]];
    
    [(UILabel*)[cell viewWithTag:2] setText:cellData[1]];
    [(UILabel*)[cell viewWithTag:3] setText:cellData[2]];
    
    cell.rippleColor = RM_COLOR;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    double delayInSeconds = 0.35;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if (indexPath.row == 0){ // change password
            [self performSegueWithIdentifier:@"changePasswordSegue" sender:nil];
            
        } else if (indexPath.row == 1) {
            [self performSegueWithIdentifier:@"optionSegue" sender:indexPath];
            
        } else if (indexPath.row == 2) { // update passcode
            [self openPasscodeView];
        }
    });
}

#pragma mark- PickerView

- (IBAction)ontouchAvatar:(id)sender {
    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Upload Avatar from" cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Select" mainColor:RM_COLOR];
    picker.delegate = self;
    picker.dataSource = self;
    picker.needFooterView = NO;
    [picker show];
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return 2;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView titleForRow:(NSInteger)row {
    if (row == 0) {
        return @"Camera";
    }
    return @"Gallery";
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    
    if (row == 0) { // open camera
        [self openMediaWithType:UIImagePickerControllerSourceTypeCamera];
        
    } else { // open gallery
        [self openMediaWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

#pragma mark- ImagePicker

- (void) openMediaWithType:(UIImagePickerControllerSourceType) type {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = type;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if ([[RMDataManagement getSharedInstance] updateAvatar:image forUser:currentUser.objectId] == YES) {
        [_profileField setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark- PassCode

- (void) openPasscodeView {
    NSString *passcode = currentUser.passcode;
    NSString *titleMessage = @"";
    if (passcode == nil || passcode.length == 0) {
        titleMessage = @"Enter New PassCode to set it ON";
    } else {
        titleMessage = @"Enter Current PassCode to set it OFF";
    }
    
    RMPasscodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier: PASSCODE_VIEW_STORYBOARD_KEY];
    vc.delegate = self;
    vc.titleText = titleMessage;
    vc.currentPasscode = passcode;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)doneActionWithPasscode:(NSString *) newPasscode {
    NSString *currentPasscode = currentUser.passcode;
    
    if ((currentPasscode == nil || currentPasscode.length == 0) && newPasscode != nil && newPasscode.length > 0) {
        // turn on passcode
        [[NSUserDefaults standardUserDefaults] setValue:newPasscode forKey:CURRENT_PASSCODE];
        
        currentUser.passcode = newPasscode;
        [[RMDataManagement getSharedInstance] updatePasscode:newPasscode forUser:currentUser.objectId];
        
        _userInfo[2] = @[@"fa-key", @"Passcode", @"ON"];
        [self.tableView reloadData];
        
    } else if (currentPasscode != nil && currentPasscode.length > 0){
        if ([newPasscode isEqualToString:currentPasscode]) {
            // turn off passcode
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:CURRENT_PASSCODE];
            
            currentUser.passcode = nil;
            [[RMDataManagement getSharedInstance] updatePasscode:nil forUser:currentUser.objectId];
            
            _userInfo[2] = @[@"fa-key", @"Passcode", @"OFF"];
            [self.tableView reloadData];
        }
    }
    
}

#pragma mark- RMOptionDelegate

- (void)optionViewsDoneWithSelectedData:(id)selectedData {
    Currency *currencyObject = (Currency *) selectedData;
    
    if ([[RMDataManagement getSharedInstance] updateCurrency:currencyObject.objectId forUser:currentUser.objectId] == YES) {
        NSString *currency = [NSString stringWithFormat:@"%@(%@)", currencyObject.name, currencyObject.symbol];
        
        currentUser.currencyName = currencyObject.name;
        currentUser.currencySymbol = currencyObject.symbol;
        
        _userInfo[1] = @[@"fa-money", @"Currency", currency];
        [_tableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCurrency object:currencyObject];
    }
}

#pragma mark- prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"changePasswordSegue"]) {
        RMChangePasswordViewController *vc = (RMChangePasswordViewController*) [segue destinationViewController];
        vc.currentUser = currentUser;
        
    } else if ([segue.identifier isEqualToString:@"optionSegue"]) {
        RMOptionsViewController *optionVC = (RMOptionsViewController*)[segue destinationViewController];
        optionVC.option = OPTION_CURRENCY;
        optionVC.delegate = self;
    }
}

@end

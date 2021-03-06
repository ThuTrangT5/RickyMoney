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
#import <Parse/PFFile.h>

@implementation RMSettingViewController {
    NSMutableArray *_userInfo;
    PFFile *_avatar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userInfo = [[NSMutableArray alloc] init];
    [self getUserInfo];
    
    _profileField.layer.cornerRadius = _profileField.frame.size.width / 2.0f;
    _profileField.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectUpdateCurrency:) name:kUpdateCurrency object:nil];
}

#pragma mark- User information
- (void) getUserInfo {
    [RMParseRequestHandler getCurrentUserInformation:^(PFObject *user) {
        NSString *currency = [NSString stringWithFormat:@"%@ (%@)", [user objectForKey:@"currencyUnit"][@"name"], [user objectForKey:@"currencyUnit"][@"symbol"]];
        NSString *passcode = [[NSUserDefaults standardUserDefaults] valueForKey:kPasscode] == nil ? @"OFF" : @"ON";
        
        _userInfo[0] = @[@"fa-envelope-o",@"Email", user[@"username"]];
        _userInfo[1] = @[@"fa-money", @"Currency", currency];
        _userInfo[2] = @[@"fa-key", @"Passcode", passcode];
        [self.tableView reloadData];
        
        _avatar = [user valueForKey:@"avatar"];
        if (_avatar != nil) {
            [_avatar getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                if (data != nil && error == nil ) {
                    UIImage *image = [[UIImage alloc] initWithData:data];
                    [_profileField setBackgroundImage:image forState:UIControlStateNormal];
                }
            }];
        }
    }];
}

- (void) detectUpdateCurrency:(NSNotification*) notification {
    if (notification.object != nil) {
        PFObject *currencyObject = (PFObject*) notification.object;
        NSString *currency = [NSString stringWithFormat:@"%@ (%@)", [currencyObject objectForKey:@"name"], [currencyObject objectForKey:@"symbol"]];
        _userInfo[1] = @[@"fa-money", @"Currency", currency];
        [_tableView reloadData];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSArray *cellData = _userInfo[indexPath.row];
    
    UIImageView *icon = (UIImageView*)[cell viewWithTag:1];
    [icon setContentMode:UIViewContentModeCenter];
    [icon setImage: [UIImage imageWithIcon:cellData[0] backgroundColor:[UIColor clearColor] iconColor: RM_COLOR andSize:CGSizeMake(30, 25)]];
    
    [(UILabel*)[cell viewWithTag:2] setText:cellData[1]];
    [(UILabel*)[cell viewWithTag:3] setText:cellData[2]];
    
    if (indexPath.row == 0) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [(UILabel*)[cell viewWithTag:3] setTextAlignment:NSTextAlignmentCenter];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [(UILabel*)[cell viewWithTag:3] setTextAlignment:NSTextAlignmentRight];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"optionSegue" sender:indexPath];
        
    } else if (indexPath.row == 2){
        [self openPasscodeView];
    }
}

#pragma mark- PickerView

- (IBAction)ontuuchAvatar:(id)sender {
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
    [_profileField setBackgroundImage:image forState:UIControlStateNormal];
    
    // Create a pointer to an object of class Point with id dlkj83d
    PFUser *userPointer = [PFUser objectWithoutDataWithObjectId:[PFUser currentUser].objectId];
    PFFile *newAvatar = [PFFile fileWithData:UIImagePNGRepresentation(image)];
    
    // Set a new value on quantity
    [userPointer setObject:newAvatar forKey:@"avatar"];
    
    // Save
    [userPointer saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            _avatar = newAvatar;
        }
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark- PassCode

- (void) openPasscodeView {
    NSString *passcode = [[NSUserDefaults standardUserDefaults] valueForKey:kPasscode];
    NSString *titleMessage = @"";
    if (passcode == nil || passcode.length == 0) {
        titleMessage = @"Enter New PassCode to set it ON";
    } else {
        titleMessage = @"Enter Current PassCode to set it OFF";
    }
    
    RMPasscodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier: PASSCODE_VIEW_STORYBOARD_KEY];
    vc.delegate = self;
    vc.titleText = titleMessage;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)doneActionWithPasscode:(RMPasscodeViewController *) passcodeVC {
    NSString *currentPasscode = [[NSUserDefaults standardUserDefaults] valueForKey:kPasscode];
    NSString *newPasscode = passcodeVC.passcodeField.text;
    
    if ((currentPasscode == nil || currentPasscode.length == 0) && newPasscode != nil && newPasscode.length > 0) {
        // turn on passcode
        [[NSUserDefaults standardUserDefaults] setValue:newPasscode forKey:kPasscode];
        _userInfo[2] = @[@"fa-key", @"Passcode", @"ON"];
        [self.tableView reloadData];
        
        [passcodeVC dismissViewControllerAnimated:YES completion:nil];
        
    } else if (currentPasscode != nil && currentPasscode.length > 0){
        if ([newPasscode isEqualToString:currentPasscode]) {
            // turn off passcode
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPasscode];
            _userInfo[2] = @[@"fa-key", @"Passcode", @"OFF"];
            [self.tableView reloadData];
            [passcodeVC dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            [passcodeVC passcodeIsWrong];
        }
    }
    
}

#pragma mark- RMOptionDelegate
- (void)optionViewsDoneWithSelectedData:(id)selectedData {
    PFObject *currencyObject = (PFObject*) selectedData;
    [RMParseRequestHandler updateCurrencyUnit:currencyObject.objectId bllock:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCurrency object:currencyObject];
    
    NSString *currency = [NSString stringWithFormat:@"%@ (%@)", [currencyObject objectForKey:@"name"], [currencyObject objectForKey:@"symbol"]];
    _userInfo[1] = @[@"fa-money", @"Currency", currency];
    [_tableView reloadData];
}

#pragma mark- prepareForSegue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"optionSegue"]) {
        RMOptionsViewController *optionVC = (RMOptionsViewController*)[segue destinationViewController];
        optionVC.option = OPTION_CURRENCY;
        optionVC.delegate = self;
    }
}

@end

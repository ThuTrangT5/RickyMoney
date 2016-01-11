//
//  RMPasscodeViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 10/28/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import "RMPasscodeViewController.h"
#import "RMConstant.h"

@implementation RMPasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set passcode
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *passcode = [ud objectForKey:kPasscode];
    if (passcode == nil || passcode.length < 5) {
        _isLock = NO;
        _passcodeField.text = passcode;
        _retypeField.text = passcode;
        _titleField.text = kPasscodeOff;
        [_turnOnOffButton setTitle:@"Turn ON" forState:UIControlStateNormal];
        
    } else {
        _isLock = TRUE;
        _titleField.text = kPasscodeOn;
        [_turnOnOffButton setTitle:@"Turn OFF" forState:UIControlStateNormal];
    }
}

- (IBAction)turnOnOffPasscodeAction:(UIButton *)sender {
    if (_isLock == TRUE) {
        // Type current Passcode to turn off
        
        THPinViewController *pinViewController = [[THPinViewController alloc] initWithDelegate:self];
        pinViewController.promptTitle = @"Enter current Passcode to turn off";
        pinViewController.promptColor =  RM_COLOR;
        pinViewController.view.tintColor = RM_COLOR;
        pinViewController.hideLetters = YES;
        
        // for a translucent background, use this:
        self.view.tag = THPinViewControllerContentViewTag;
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        pinViewController.translucentBackground = YES;
        
        [self presentViewController:pinViewController animated:YES completion:nil];
        
    } else {
        // validate passcode
        NSString *errorMess = @"";
        if (_passcodeField.text.length < 5) {
            errorMess = @"Passcode must have as least 5 characters.";
            
        } else if ([_retypeField.text isEqualToString:_passcodeField.text] == NO) {
            errorMess = @"Passcode & Retype are not the same.";
        }
        
        // show error message or turn on passcode
        if (errorMess.length > 0) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:errorMess
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil]
             show];
            
        } else {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:_passcodeField.text forKey:kPasscode];
            
            _titleField.text = kPasscodeOn;
            _isLock = YES;
            [_turnOnOffButton setTitle:@"Turn OFF" forState:UIControlStateNormal];
        }
    }
}

#pragma mark- THPinViewController delegate

- (NSUInteger)pinLengthForPinViewController:(THPinViewController *)pinViewController {
    return 5;
}

- (BOOL)pinViewController:(THPinViewController *)pinViewController isPinValid:(NSString *)pin {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *correctPasscode = [ud objectForKey:kPasscode];
    
    if ([pin isEqualToString:correctPasscode]) {
        // turn off Passcode
        
        _titleField.text = kPasscodeOff;
        _passcodeField.text = @"";
        _retypeField.text = @"";
        _isLock = NO;
        [ud removeObjectForKey:kPasscode];
        [_turnOnOffButton setTitle:@"Turn ON" forState:UIControlStateNormal];
        
        return YES;
    } else {
        return NO;
    }
    return YES;
}

- (BOOL)userCanRetryInPinViewController:(THPinViewController *)pinViewController
{
    return YES;
}
@end

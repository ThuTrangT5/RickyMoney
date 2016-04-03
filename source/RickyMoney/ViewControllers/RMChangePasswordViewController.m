//
//  RMChangePasswordViewController.m
//  RickyMoney
//
//  Created by Thu Trang on 4/3/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMChangePasswordViewController.h"
#import "RMParseRequestHandler.h"
#import "UIImage+FontAwesome.h"

#import "RickyMoney-Swift.h"

#define Y_OFFSET 75

@implementation RMChangePasswordViewController {
    float yBeforeMoveUp;
    UITextField *currentFocusTextField;
    NSString *currentPassword;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI border
    NSArray *controls = [[NSArray alloc] initWithObjects:_emailField, _currentPasswordField, _updatePasswordField, _confirmPasswordField, nil];
    for (UIView *control in controls) {
        control.layer.cornerRadius = 10;
        control.layer.borderWidth = 0.5f;
        control.layer.borderColor = RM_COLOR.CGColor;
    }
    
    // insert tick image for save button
    CGSize size = CGSizeMake(20, 20);
    UIImage *tick = [UIImage imageWithIcon:@"fa-check" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] andSize:size];
    UIImageView *tickView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [tickView setImage:tick];
    [[self.view viewWithTag:10] addSubview:tickView];
    
    [self getCurrentUserInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    yBeforeMoveUp = self.view.frame.origin.y;
}

#pragma mark - Data

- (void) getCurrentUserInfo {
    [RMParseRequestHandler getCurrentUserInformation:^(PFObject* user) {
        currentPassword = [user valueForKey:@"password"];
        
    }];
}

#pragma mark- UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    UITextField *nextTextField = (UITextField*)[self.view viewWithTag:textField.tag +1];
    if (nextTextField != nil) {
        [nextTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currentFocusTextField = textField;
}

#pragma mark- Actions

- (BOOL) validate {
    NSString *message = nil;
    if (_currentPasswordField.text.length == 0) {
        message = @"Please input the correct current password.";
        //        UNAlertView *alert = [UNAlertView ];
    }
    
    if (_updatePasswordField.text.length < 6) {
        message = @"New password has 6 characters atleast.";
    }
    
    if ([_updatePasswordField.text isEqualToString:_confirmPasswordField.text] == NO) {
        message = @"Confirm new password is incorrect.";
    }
    
    return YES;
    
}

- (IBAction)ontouchChangePassword:(id)sender {
    if ([self validate]) {
        
    }
}


#pragma mark- Keyboard

- (void) keyboardWillShow {
    if (currentFocusTextField.frame.origin.y > Y_OFFSET) {
        
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y -= Y_OFFSET;
            self.view.frame = frame;
        }];
    }
}

- (void) keyboardWillHide {
    if (currentFocusTextField.frame.origin.y > Y_OFFSET) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = self.view.frame;
            frame.origin.y = yBeforeMoveUp;
            self.view.frame = frame;
        }];
    }
}

@end

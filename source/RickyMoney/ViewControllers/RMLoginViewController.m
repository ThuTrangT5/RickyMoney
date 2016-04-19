//
//  RMLoginViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 9/5/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMLoginViewController.h"
#import "AppDelegate.h"
#import "RMConstant.h"
#import "UIImage+FontAwesome.h"

#import "RMDataManagement.h"
#import "RMFireBaseManagement.h"
#import "TTAlertView.h"

#define DATE_FORMAT @"yyyy-MM-dd"

@implementation RMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // insert fontawesome images
    CGSize size = CGSizeMake(25, 25);
    _emailImage.image = [UIImage imageWithIcon:@"fa-envelope-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] andSize:size];
    _passwordImage.image = [UIImage imageWithIcon:@"fa-lock" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] andSize:size];
    
    NSArray *imgButtons = [[NSArray alloc] initWithObjects:@"fa-sign-in", @"fa-plus", @"fa-facebook", @"fa-twitter", nil];
    NSArray *colorButtons = [[NSArray alloc] initWithObjects:[UIColor whiteColor], RM_COLOR, [UIColor whiteColor], [UIColor whiteColor], nil];
    for (int i = 0; i < imgButtons.count; i++) {
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
        view.image = [UIImage imageWithIcon:imgButtons[i] backgroundColor:[UIColor clearColor] iconColor:colorButtons[i] andSize:CGSizeMake(20, 20)];
        UIButton *button = (UIButton*) [self.view viewWithTag:i+1];
        [button addSubview:view];
    }
    
    // tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    // download remote data
    [RMFireBaseManagement getRemoteData];
    
}

- (void)viewDidAppear:(BOOL)animated {
    _emailField.text = @"";
    _passwordField.text = @"";
    
    NSString *loginEmail = [[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_EMAIL];
    NSString *loginPassword = [[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_PASSWORD];
    
    if (loginEmail != nil && loginPassword != nil) {
        // check time out login
        NSString *loginDate = [[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_DATE];
        if (loginDate != nil) {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = DATE_FORMAT;
            
            NSDate *fromDate = [formatter dateFromString:loginDate];
            NSDate *toDate = [NSDate new];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *difference = [calendar components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
            
            long days = [difference day];
            if (days < TIMEOUT_LOGIN_DAYS) {
                NSLog(@"Already Logined with %@/%@", loginEmail, loginPassword);
                
                _emailField.text = loginEmail;
                _passwordField.text = loginPassword;
                [self loginAction:nil];
                
                //                [(AppDelegate*)[[UIApplication sharedApplication] delegate] loginSuccess];
            }
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_EMAIL];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_PASSWORD];
        }
    }
}

#pragma mark- Login Actions

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)loginAction:(id)sender {
    if ([self validate]) {
        
        [RMFireBaseManagement loginWithEmail:_emailField.text andPassword:_passwordField.text successBlock:^(NSString *userId) {
            if (userId != nil) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = DATE_FORMAT;
                NSString *loginedDate = [formatter stringFromDate:[NSDate new]];
                
                [[NSUserDefaults standardUserDefaults] setValue:loginedDate forKey:LOGIN_DATE];
                [[NSUserDefaults standardUserDefaults] setValue:userId forKey:CURRENT_USER_ID];
                [[NSUserDefaults standardUserDefaults] setValue:_emailField.text forKey:LOGIN_EMAIL];
                [[NSUserDefaults standardUserDefaults] setValue:_passwordField.text forKey:LOGIN_PASSWORD];
                
                [(AppDelegate*)[[UIApplication sharedApplication] delegate] loginSuccess];
            }
        }];
    }
}

- (IBAction)signUpAction:(id)sender {
    
    if ([self validate]) {
        
        [RMFireBaseManagement signupWithEmail:_emailField.text andPassword:_passwordField.text successBlock:^(NSString *userId) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = DATE_FORMAT;
            NSString *loginedDate = [formatter stringFromDate:[NSDate new]];
            
            [[NSUserDefaults standardUserDefaults] setValue:loginedDate forKey:LOGIN_DATE];
            [[NSUserDefaults standardUserDefaults] setValue:userId forKey:CURRENT_USER_ID];
            
            [(AppDelegate*)[[UIApplication sharedApplication] delegate] loginSuccess];
        }];
    }
}

- (IBAction)facebookLoginAction:(id)sender {
}

- (IBAction)twitterLoginAction:(id)sender {
}

#pragma mark- Validate

-(BOOL) NSStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL) validate {
    BOOL isValid = YES;
    NSString *errorMessage = @"";
    
    if (self.emailField.text.length == 0 || ![self NSStringIsValidEmail:self.emailField.text]) {
        isValid = NO;
        errorMessage = @"Please input a valid Email.";
    }
    
    if (self.passwordField.text.length < 6) {
        isValid = NO;
        errorMessage = [NSString stringWithFormat:@"%@\n%@", errorMessage, @"Please input Password at least 6 characters."];
    }
    
    if (!isValid) {
        TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Login Error"
                                                andErrorMessage:errorMessage];
        [alert show];
    }
    
    return isValid;
}

@end
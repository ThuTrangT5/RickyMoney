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
#import <Parse/PFUser.h>

#import "RMDataManagement.h"

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
    
    // testing
    _emailField.text = @"thutrangitmt@gmail.com";
    _passwordField.text = @"111111";
}

- (void)viewDidAppear:(BOOL)animated {
    
    // check already login
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser && currentUser.objectId != nil) {
        NSLog(@"Already Logined with id = %@", currentUser.objectId);
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] loginSuccess];
        
    } else {
        // show the signup or login screen
    }
}

#pragma mark- Login Actions

- (void) dismissKeyboard {
    [self.view endEditing:YES];
}

- (IBAction)loginAction:(id)sender {
    

    if ([self validate]) {
        
        [[RMDataManagement getSharedInstance] loginWithEmail:self.emailField.text andPassword:self.passwordField.text];
        
        [PFUser logInWithUsernameInBackground:self.emailField.text password:self.passwordField.text block:^(PFUser *user, NSError *error) {
            if (user) {
                [(AppDelegate*)[[UIApplication sharedApplication] delegate] loginSuccess];
                
            } else {
                // The login failed. Check error to see why.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:[error userInfo][@"error"]
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }];
    }
}

- (IBAction)signUpAction:(id)sender {
    
    if ([self validate]) {
        
        [[RMDataManagement getSharedInstance] createNewUserWithEmail:self.emailField.text password:self.passwordField.text];
        
        PFUser *user = [PFUser user];
        user.username = self.emailField.text;
        user.password = self.passwordField.text;
        user.email = self.emailField.text;
        
        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // Hooray! Let them use the app now.
                [(AppDelegate*)[[UIApplication sharedApplication] delegate] loginSuccess];
                
            } else {
                // Show the errorString somewhere and let the user try again.
                NSString *errorString = [error userInfo][@"error"];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:errorString
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:errorMessage
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    return isValid;
}

@end
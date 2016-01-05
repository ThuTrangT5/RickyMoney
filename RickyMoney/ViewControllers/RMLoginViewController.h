//
//  RMLoginViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/5/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *emailImage;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImage;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

- (IBAction)loginAction:(id)sender;
- (IBAction)signUpAction:(id)sender;
- (IBAction)facebookLoginAction:(id)sender;
- (IBAction)twitterLoginAction:(id)sender;

@end

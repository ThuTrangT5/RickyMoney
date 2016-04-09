//
//  RMChangePasswordViewController.h
//  RickyMoney
//
//  Created by Thu Trang on 4/3/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMObjects.h"

@interface RMChangePasswordViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) User *currentUser;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *currentPasswordField;
@property (weak, nonatomic) IBOutlet UITextField *updatePasswordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;

- (IBAction)ontouchChangePassword:(id)sender;

@end

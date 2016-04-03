//
//  RMPasscodeViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 10/28/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <THPinViewController/THPinViewController.h>

@interface RMPasscodeViewController : UIViewController <THPinViewControllerDelegate>

@property (nonatomic) BOOL isLock;
@property (weak, nonatomic) IBOutlet UILabel *titleField;
@property (weak, nonatomic) IBOutlet UITextField *passcodeField;
@property (weak, nonatomic) IBOutlet UITextField *retypeField;
@property (weak, nonatomic) IBOutlet UIButton *turnOnOffButton;

- (IBAction)turnOnOffPasscodeAction:(UIButton *)sender;
@end

//
//  RMPasscodeViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 10/28/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <THPinViewController/THPinViewController.h>

@protocol PasscodeDelegate <NSObject>

- (void) doneActionWithPasscode:(UIViewController*) passcodeVC;

@end

@interface RMPasscodeViewController : UIViewController

/* UITextField to store passcode text */
@property (weak, nonatomic) IBOutlet UITextField *passcodeField;

/* Delegate */
@property (nonatomic, weak) id<PasscodeDelegate> delegate;

/* The background color for control buttons */
@property (nonatomic, strong) UIColor *mainColor;

@end

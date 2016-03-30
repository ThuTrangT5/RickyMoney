//
//  RMPasscodeViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 10/28/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <THPinViewController/THPinViewController.h>

@class RMPasscodeViewController;

@protocol RMPasscodeDelegate <NSObject>

- (void) doneActionWithPasscode:(RMPasscodeViewController*) passcodeController;

@end

@interface RMPasscodeViewController : UIViewController

/* Title Field */
@property (weak, nonatomic) IBOutlet UILabel *titleField;

/* UITextField to store passcode text */
@property (weak, nonatomic) IBOutlet UITextField *passcodeField;

/* Delegate */
@property (nonatomic, weak) id<RMPasscodeDelegate> delegate;

/* The background color for control buttons */
@property (nonatomic, strong) UIColor *mainColor;

@property (nonatomic, strong) NSString *titleText;

- (void) displayView;
- (void) passcodeIsWrong;

@end

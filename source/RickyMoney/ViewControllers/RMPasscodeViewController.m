//
//  RMPasscodeViewController.m
//  RickyMoney
//
//  Created by Adelphatech on 10/28/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import "RMPasscodeViewController.h"
#import "RMConstant.h"

#define DEFAULT_MAIN_COLOR [UIColor colorWithRed:230.0/255.0 green:194.0/255.0 blue:32.0/255.0 alpha:1.0]

@implementation RMPasscodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUIForNumberButtons];
    [self setUIForControlButtons];
    [self setBlurBackground];
    
    _passcodeField.text = @"";
    _titleField.text = @"";
    
    if (_titleText == nil) {
        NSString *passcode = [[NSUserDefaults standardUserDefaults] valueForKey:kPasscode] == nil ? @"OFF" : @"ON";
        if ([passcode isEqualToString:@"ON"]) {
            _titleField.text = @"Input PASSCODE to close this view.";
            // hide button "Hide"
            [self.view viewWithTag:1].hidden = YES;
        }
        
    } else {
        _titleField.text = _titleText;
    }
}

#pragma mark- UI setup

- (void) setUIForNumberButtons {
    for (int i = 18; i <= 29; i++) {
        UIButton *numberButton = (UIButton *)[self.view viewWithTag:i];
        numberButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        numberButton.layer.borderWidth = 1.0f;
        
        if (i >= 20) {
            [numberButton addTarget:self action:@selector(ontouchNumber:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void) setUIForControlButtons {
    
    if (_mainColor == nil) {
        _mainColor = DEFAULT_MAIN_COLOR;
    }
    
    for (int i = 1; i <= 2; i++) {
        UIView *btn = [self.view viewWithTag:i];
        btn.layer.borderColor = [[UIColor whiteColor] CGColor];
        btn.layer.borderWidth = 1.0f;
        btn.layer.cornerRadius = btn.frame.size.height / 2.0;
        btn.backgroundColor = _mainColor;
    }
}

- (void) setBlurBackground {
    //only apply the blur if the user hasn't disabled transparency effects
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        UIView *maskView = [self.view viewWithTag:10];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [maskView addSubview:blurEffectView];
    }
}

#pragma mark- Actions

- (IBAction)ontouchNumber:(UIButton*)sender {
    NSString *passcode = _passcodeField.text;
    NSString *title = [sender titleForState:UIControlStateNormal];
    passcode = [NSString stringWithFormat:@"%@%@", passcode, title];
    _passcodeField.text = passcode;
}

- (IBAction) ontouchClear:(id)sender {
    _passcodeField.text = @"";
}

- (IBAction) ontouchBackDelete:(id)sender {
    NSString *currentCode = _passcodeField.text;
    if (currentCode.length <= 1) {
        _passcodeField.text = @"";
    } else {
        currentCode = [currentCode substringToIndex:currentCode.length - 1];
        _passcodeField.text = currentCode;
    }
}

- (IBAction) ontouchHidePasscode:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ontouchDonePasscode:(id)sender {
    if (self.delegate) {
        [self.delegate doneActionWithPasscode: self];
    } else {
        NSString *passcode = [[NSUserDefaults standardUserDefaults] valueForKey:kPasscode];
        if (passcode != nil && [_passcodeField.text isEqualToString:passcode] == NO) {
            [self passcodeIsWrong];
            
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark- Utils

- (void)displayView {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc presentViewController:self animated:YES completion:nil];
}

- (void) passcodeIsWrong {
    [self animatePasscodeWithTime:5];
}

- (void) animatePasscodeWithTime:(int) time {
    float xTransform = (time % 2 == 0) ? -10 : 10;
    xTransform = xTransform * time;
    
    _passcodeField.textColor = [UIColor redColor];
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         _passcodeField.transform = CGAffineTransformMakeTranslation(xTransform, 0);
                     }
                     completion:^(BOOL finished) {
                         if (time > 0) {
                             [self animatePasscodeWithTime:time - 1];
                             
                         } else {
                             _passcodeField.textColor = [UIColor whiteColor];
                         }
                     }
     ];
}
@end

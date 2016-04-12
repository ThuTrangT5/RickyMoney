//
//  RMProgressCell.m
//  RickyMoney
//
//  Created by Thu Trang on 4/10/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMProgressCell.h"
#import "RMConstant.h"

#define DELTA_VALUE 0.05
#define TIME_INTERVAL 0.2

@implementation RMProgressCell {
    float progressValue, maxProgressValue;
    NSTimer *_timer;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    ASProgressPopUpView *progressView = (ASProgressPopUpView *)[self viewWithTag:1];
    progressView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    progressView.popUpViewAnimatedColors = @[ RM_COLOR, [UIColor redColor]];
    progressView.progress = 0.0;
    
    progressView.delegate = self;
    progressView.dataSource = self;
}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//}

#pragma mark- Actions

- (void) setProgressValue:(float) currentValue maxValue:(float) maxValue {
    progressValue = currentValue;
    maxProgressValue = maxValue;
    ASProgressPopUpView *progressView =  (ASProgressPopUpView *)[self viewWithTag:1];
    progressView.progress = 0.5;
    [progressView hidePopUpViewAnimated: YES];
    
    [UIView animateWithDuration:0.5 animations:^{} completion:^(BOOL finished) {
       [self progress];
    }];
}

- (void) setCategoryName:(NSString*) category {
    UILabel *label = (UILabel*)[self viewWithTag:2];
    [label setText:category];
}

- (void) setBudgetValue:(NSString*) budget {
    UILabel *label = (UILabel*)[self viewWithTag:3];
    [label setText:budget];
}


#pragma mark- ASProgressPopUpView

- (void)progressViewWillDisplayPopUpView:(ASProgressPopUpView *)progressView {
    [self.superview bringSubviewToFront:self];
}

- (NSString *)progressView:(ASProgressPopUpView *)progressView stringForProgress:(float)progress {
    NSString *text = [NSString stringWithFormat:@" %.2f ", progressValue];
    if (_currencySymbol != nil) {
        text = [_currencySymbol stringByAppendingString:text];
    }
    
    return text;
}

- (BOOL)progressViewShouldPreCalculatePopUpViewSize:(ASProgressPopUpView *)progressView;{
    return NO;
}

#pragma mark - Timer

- (void)progress {
    
    ASProgressPopUpView *progressView = (ASProgressPopUpView*) [self viewWithTag:1];
    float progress = progressView.progress;
    if (progress < (progressValue / maxProgressValue) && progress < 1) {
        progress += (progressValue / maxProgressValue) / 5.0;
        [progressView setProgress:progress animated: YES];
        
        [NSTimer scheduledTimerWithTimeInterval: TIME_INTERVAL
                                         target:self
                                       selector:@selector(progress)
                                       userInfo:nil
                                        repeats:NO];
    } else {
        progress = progressValue / maxProgressValue;
        if (progress > 1) {
            progress = 1;
        }
        [progressView showPopUpViewAnimated: YES];
    }
}
@end

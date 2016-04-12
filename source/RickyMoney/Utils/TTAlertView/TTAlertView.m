//
//  TTAlertView.m
//  RickyMoney
//
//  Created by Thu Trang on 4/11/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "TTAlertView.h"

@interface TTAlertView () {
    NSString *_titleAlert, *_messageAlert, *_cancelButtonTitle;
    float _animationDuration;
}

@property UIView *backgroundDimmingView;
@property (strong, nonatomic) UIView *contentView;

@property (strong, nonatomic) UILabel *titleField;
@property (strong, nonatomic) UILabel *messageField;
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation TTAlertView

- (void)commonInit {
    
    // default value
    _mainColor = [UIColor colorWithRed:230.0/255.0 green:194.0/255.0 blue:32.0/255.0 alpha:1.0]; // # e6c220
    _titleAlert = @"Title";
    _messageAlert = @"";
    _cancelButtonTitle = @"OK";
    
    _animationDuration = 0.3;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title andMessage:(NSString *)message {
    self = [super init];
    if (self) {
        [self commonInit];
        
        _titleAlert = title;
        _messageAlert = message;
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title andErrorMessage:(NSString *)message {
    self = [super init];
    if (self) {
        [self commonInit];
        
        _titleAlert = title;
        _messageAlert = message;
        _mainColor = [UIColor redColor];
    }
    
    return self;
}

#pragma mark- Create UI controls

- (void) setupUI {
    if (_backgroundDimmingView == nil) {
        _backgroundDimmingView = [self createBackgroundDimmingView];
        [self addSubview:_backgroundDimmingView];
    }
    
    if (_contentView == nil) {
        _contentView = [self createContentView];
        [self addSubview:_contentView];
    }
    
    if (_titleField == nil) {
        _titleField = [self createTitleView];
        [_contentView addSubview:_titleField];
    }
    
    if (_cancelButton == nil) {
        _cancelButton = [self createCancelButton];
        [_contentView addSubview:_cancelButton];
    }
    
    // set title
    [_titleField setText:_titleAlert];
    [_messageField setText:_messageAlert];\
    [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];

}

- (UIView *)createBackgroundDimmingView{
    
    UIView *bgView;
    //blur effect for iOS8
    CGFloat frameHeight = self.bounds.size.height;
    CGFloat frameWidth = self.bounds.size.width;
    CGFloat sideLength = frameHeight > frameWidth ? frameHeight : frameWidth;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
        UIBlurEffect *eff = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        bgView = [[UIVisualEffectView alloc] initWithEffect:eff];
        bgView.frame = CGRectMake(0, 0, sideLength, sideLength);
    }
    else {
        bgView = [[UIView alloc] initWithFrame:self.frame];
        bgView.backgroundColor = [UIColor blackColor];
    }
    bgView.alpha = 0.0;
    
    return bgView;
}

- (UIView*) createContentView {
    CGAffineTransform transform = CGAffineTransformMake(0.88, 0, 0, 0.55, 0, 0);
    CGRect newRect = CGRectApplyAffineTransform(self.frame, transform);
    UIView *cv = [[UIView alloc] initWithFrame:newRect];
    [cv setBackgroundColor:[UIColor whiteColor]];
    [cv.layer setCornerRadius:10.0f];
    [cv.layer setBorderWidth:1.0f];
    [cv.layer setBorderColor:_mainColor.CGColor];
    [cv.layer setMasksToBounds:YES];
    
    return cv;
}

- (UILabel*) createTitleView {
    CGRect frame = _contentView.bounds;
    frame.size.height = 50;
    UILabel *tv = [[UILabel alloc] initWithFrame:frame];
    tv.textAlignment = NSTextAlignmentCenter;
    tv.font = [UIFont systemFontOfSize:18.0];
    tv.textColor = _mainColor;
//    tv.backgroundColor = _mainColor;
    
    return tv;
}

- (UILabel*) createMessageView {
    CGRect frame = _contentView.bounds;
    frame.size.height = 50;
    frame.origin.y = 50;
    UILabel *mv = [[UILabel alloc] initWithFrame:frame];
    mv.textAlignment = NSTextAlignmentCenter;
    mv.font = [UIFont systemFontOfSize:18.0];
    mv.textColor = _mainColor;
    
    return mv;
}

- (UIButton*) createCancelButton {
    CGRect frame = _contentView.bounds;
    frame.origin.y = frame.size.height - 50;
    frame.size.height = 50;
    frame.size.width = frame.size.width / 2.0f;
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:frame];
    [cancel setTitleColor:_mainColor forState:UIControlStateNormal];
    [cancel.layer setBorderWidth:1.0f];
    [cancel.layer setBorderColor:_mainColor.CGColor];
    
    [cancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cancel;
}


#pragma mark- Actions

- (void)show {
    
}

- (void) dismissAlertView {
    [UIView animateWithDuration:_animationDuration
                          delay:0
         usingSpringWithDamping:0.7f
          initialSpringVelocity:3.0f
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.contentView.center = CGPointMake(self.center.x, self.center.y + self.frame.size.height);
                     }
                     completion:^(BOOL finished) {}
     ];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.backgroundDimmingView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             [self removeFromSuperview];
                         }
                     }
     ];
}

- (void) cancelAction:(id)sender {
    [self dismissAlertView];
}

@end

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
@property (strong, nonatomic) UITextView *messageField;
@property (strong, nonatomic) UIButton *cancelButton;

@end

#define TT_BACKGROUND_ALPHA 0.9

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
        
        // check for error network
        if ([message containsString:@"NETWORK_ERROR"]) {
            message = @"This function require internet connection.";
        }
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
    
    if ( _titleAlert != nil && _titleAlert.length > 0 && _titleField == nil) {
        _titleField = [self createTitleView];
        [_contentView addSubview:_titleField];
    }
    
    if (_messageField == nil) {
        _messageField = [self createMessageView];
        [_contentView addSubview:_messageField];
    }
    
    if (_cancelButton == nil) {
        _cancelButton = [self createCancelButton];
        [_contentView addSubview:_cancelButton];
    }
    
    // set title
    [_titleField setText:_titleAlert];
    [_messageField setText:_messageAlert];\
    [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
    
    // update fit size
    CGFloat fixedWidth = _messageField.frame.size.width;
    CGSize newSize = [_messageField sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = _messageField.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    _messageField.frame = newFrame;
    
    CGRect frame = _contentView.frame;
    frame.size.height = _titleField.frame.size.height + newFrame.size.height + 50;
    _contentView.frame = frame;
    
    frame = _cancelButton.frame;
    frame.origin.y = newFrame.origin.y + newFrame.size.height;
    _cancelButton.frame = frame;
    
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
    CGAffineTransform transform = CGAffineTransformMake(0.88, 0, 0, 0.25, 0, 0);
    CGRect newRect = CGRectApplyAffineTransform(self.frame, transform);
    UIView *cv = [[UIView alloc] initWithFrame:newRect];
    [cv setBackgroundColor:[UIColor whiteColor]];
    [cv.layer setCornerRadius:10.0f];
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
    
    return tv;
}

- (UITextView*) createMessageView {
    CGRect frame = _contentView.bounds;
    frame.size.height -= (50 + 50);
    frame.origin.y = (_titleField == nil) ? 0 : 50;
    UITextView *mv = [[UITextView alloc] initWithFrame:frame];    
    mv.textAlignment = NSTextAlignmentCenter;
    mv.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    mv.editable = NO;
    
    return mv;
}

- (UIButton*) createCancelButton {
    CGRect frame = _contentView.bounds;
    frame.origin.y = frame.size.height - 50;
    frame.size.height = 50;
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:frame];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancel setBackgroundColor:_mainColor];
    
    [cancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cancel;
}

#pragma mark- Actions

- (void)show {
    // add to current top view controller
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    self.frame = mainWindow.frame;
    
    [mainWindow addSubview:self];
    [self setupUI];
    
    
    // start animation
    self.contentView.center = CGPointMake(self.center.x, self.center.y + self.frame.size.height);
    [self performContainerAnimation];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundDimmingView.alpha = TT_BACKGROUND_ALPHA;
    }];
}

- (void)performContainerAnimation {
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:3.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.contentView.center = self.center;
    } completion:^(BOOL finished) {
        
    }];
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

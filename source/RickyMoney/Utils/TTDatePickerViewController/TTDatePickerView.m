//
//  TTDatePickerView.m
//  RickyMoney
//
//  Created by Adelphatech on 10/26/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import "TTDatePickerView.h"

@interface TTDatePickerView ()
@property (strong, nonatomic) UIView *contentView;

@property (strong, nonatomic) UILabel *titleField;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) UIDatePicker *datePicker;

@property UIView *backgroundDimmingView;
/** picker's animation duration for showing and dismissing*/
@property CGFloat animationDuration;

@end

#define TT_BACKGROUND_ALPHA 0.9

@implementation TTDatePickerView

- (instancetype) init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    
    // default value
    _mainColor = [UIColor blackColor];
    _titlePicker = @"Title";
    _confirmButtonTitle = @"Set date";
    _cancelButtonTitle = @"Cancel";
    _datePickerMode = UIDatePickerModeDate;
    
    _animationDuration = 0.3;
}

- (void)setupUI {
    
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
    
    if (_confirmButton == nil) {
        _confirmButton = [self createConfirmButton];
        [_contentView addSubview:_confirmButton];
    }
    
    if (_datePicker == nil) {
        _datePicker = [self createDatePicker];
        [_contentView addSubview:_datePicker];
    }
    
    // set title
    [_titleField setText:_titlePicker];
    [_confirmButton setTitle:_confirmButtonTitle forState:UIControlStateNormal];
    [_cancelButton setTitle:_cancelButtonTitle forState:UIControlStateNormal];
    
    // datepicker
    if (_minDate != nil) {
        [_datePicker setMinimumDate:_minDate];
    }
    if (_maxDate != nil) {
        [_datePicker setMaximumDate:_maxDate];
    }
    if (_date != nil) {
        [_datePicker setDate:_date];
    }
    if (_datePickerMode) {
        [_datePicker setDatePickerMode:_datePickerMode];
    }
}

#pragma mark- Create UI controls

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
    
    // add tapgesture to dismis view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPicker)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [bgView addGestureRecognizer:tap];
    
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
    tv.textColor = [UIColor whiteColor];
    tv.backgroundColor = _mainColor;
    
    return tv;
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

- (UIButton*) createConfirmButton {
    CGRect frame = _contentView.bounds;
    frame.origin.y = frame.size.height - 50;
    frame.origin.x = frame.size.width / 2.0f;
    frame.size.height = 50;
    frame.size.width = frame.size.width / 2.0f;
    
    UIButton *confirm = [[UIButton alloc] initWithFrame:frame];
    [confirm setTitleColor:_mainColor forState:UIControlStateNormal];
    [confirm.layer setBorderWidth:1.0f];
    [confirm.layer setBorderColor:_mainColor.CGColor];
    
    [confirm addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return confirm;
}

- (UIDatePicker*) createDatePicker {
    CGRect frame = _contentView.bounds;
    frame.origin.y += 50;
    frame.size.height -= 100;
    
    UIDatePicker *pv = [[UIDatePicker alloc] initWithFrame:frame];
    pv.datePickerMode = UIDatePickerModeDate;
    
    return pv;
}

#pragma mark- Actions

- (IBAction)confirmAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(ttDatePickerPickedDate:)]) {
        NSDate *selectedDate = [_datePicker date];
        [_delegate ttDatePickerPickedDate:selectedDate];
    }
    
    [self dismissPicker];
    
}

- (IBAction)cancelAction:(id)sender {
    [self dismissPicker];
}

#pragma mark- Animations

- (void)performContainerAnimation {
    
    [UIView animateWithDuration:self.animationDuration
                          delay:0
         usingSpringWithDamping:0.7f
          initialSpringVelocity:3.0f
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         self.contentView.center = self.center;
                     }
                     completion:nil
     ];
}

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

- (void)dismissPicker {
    [UIView animateWithDuration:self.animationDuration
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

@end

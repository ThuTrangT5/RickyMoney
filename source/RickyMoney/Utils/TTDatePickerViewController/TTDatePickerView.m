//
//  TTDatePickerView.m
//  RickyMoney
//
//  Created by Adelphatech on 10/26/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import "TTDatePickerView.h"

@interface TTDatePickerView ()
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *titleField;
@property (weak, nonatomic) IBOutlet UIView *separator1;
@property (weak, nonatomic) IBOutlet UIView *separator2;
@property (weak, nonatomic) IBOutlet UIView *separator3;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

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
    
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RMDatePicker" owner:self options:nil];
    UIView *xibView = (UIView*)[objects lastObject];
    xibView.frame = self.bounds;
    [self addSubview:xibView];
    
    // default value
    _mainColor = [UIColor blackColor];
    _titlePicker = @"Title";
    _confirmButtonTitle = @"Set date";
    _cancelButtonTitle = @"Cancel";
    _datePickerMode = UIDatePickerModeDate;
}

- (void)setupUI {
    
    // set border
    [_contentView.layer setCornerRadius:10.0f];
    //    [_contentView.layer setBorderColor:_mainColor.CGColor];
    //    [_contentView.layer setBorderWidth:2.0f];
    [_contentView.layer setMasksToBounds:YES];
    
    // set main color
    [_titleField setTextColor: [UIColor whiteColor]];
    [_titleField setBackgroundColor:_mainColor];
    
    [_confirmButton setTitleColor:_mainColor forState:UIControlStateNormal];
    [_cancelButton setTitleColor:_mainColor forState:UIControlStateNormal];
    [_separator1 setBackgroundColor:_mainColor];
    [_separator2 setBackgroundColor:_mainColor];
    [_separator3 setBackgroundColor:_mainColor];
    
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

- (UIView *)buildBackgroundDimmingView{
    
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

#pragma mark- DatePicker Actions

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

- (void)performContainerAnimation {
    
    [UIView animateWithDuration:self.animationDuration delay:0 usingSpringWithDamping:0.7f initialSpringVelocity:3.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        self.contentView.center = self.center;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)show {
    // UI
    [self setupUI];
    
    // add to current top view controller
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    self.frame = mainWindow.frame;
    
    [mainWindow addSubview:self];
    
    if (self.backgroundDimmingView == nil) {
        self.backgroundDimmingView = [self buildBackgroundDimmingView];
        UIView *xibView = [self viewWithTag:99];
        [xibView addSubview:self.backgroundDimmingView];
        [xibView bringSubviewToFront:_contentView];
    }
    
    // start animation
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
    
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundDimmingView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(finished){
            [self removeFromSuperview];
        }
    }];
}

@end

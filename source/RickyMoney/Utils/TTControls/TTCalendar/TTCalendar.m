//
//  TTCalendar.m
//  RickyMoney
//
//  Created by Thu Trang on 1/11/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "TTCalendar.h"
#import "RMConstant.h"

@implementation TTCalendar {
    NSDate *_dateSelected, *_fromDate, *_toDate;
    __weak IBOutlet UIView *contentView;
}

#define TTCalendarAnimationDuration 0.5

//-(instancetype)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//
//    if (self) {
//        self = [self initializeSubviews];
//    }
//
//    return self;
//}

- (instancetype)init {
    self = [self initializeSubviews];
    [contentView.layer setCornerRadius:10.0f];
    [contentView.layer setMasksToBounds:YES];
    contentView.center = CGPointMake(self.center.x, self.center.y + self.frame.size.height);
    
    return self;
}

- (instancetype) initCalendarWithTitle:(NSString*)  title andConfirmButton:(NSString*) buttonTitle {
    self = [super init];
    
    if (self) {
        self = [self initializeSubviews];
    }
    
    return self;
}

- (instancetype)initializeSubviews {
    id view = [[[NSBundle mainBundle] loadNibNamed:@"TTCalendarView" owner:self options:nil] firstObject];
    
    return view;
}

- (void) initCalendar {
    _calendarContentView.layer.borderColor = RM_COLOR.CGColor;
    _calendarContentView.layer.borderWidth = 1.0f;
    _calendarContentView.backgroundColor = [UIColor whiteColor];
    
    _calendarManager = [JTCalendarManager new];
    _calendarManager.delegate = self;
    
    _calendarManager.settings.pageViewHaveWeekDaysView = YES;
    _calendarManager.settings.pageViewNumberOfWeeks = 0; // Automatic
    
    [_calendarManager setMenuView:_calendarMenuView];
    [_calendarManager setContentView:_calendarContentView];
    [_calendarManager setDate:[NSDate date]];
    
    _calendarMenuView.scrollView.scrollEnabled = NO; // Scroll not supported with JTVerticalCalendarView
}

#pragma mark- JTCalendar delegate

- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    dayView.hidden = NO;
    
    // Hide if from another month
    if([dayView isFromAnotherMonth]){
        dayView.hidden = YES;
    }
    // from date
    else if (_fromDate && [_calendarManager.dateHelper date:_fromDate isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = [UIColor blueColor];
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Selected date
    else if(_dateSelected && [_calendarManager.dateHelper date:_dateSelected isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = NO;
        dayView.circleView.backgroundColor = RM_COLOR;
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor whiteColor];
    }
    // Today
    else if([_calendarManager.dateHelper date:[NSDate date] isTheSameDayThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor whiteColor];
        dayView.textLabel.textColor = [UIColor redColor];
        dayView.textLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    }
    // Other month
    else if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor lightGrayColor];
    }
    // Another day of the current month
    else{
        dayView.circleView.hidden = YES;
        dayView.dotView.backgroundColor = [UIColor redColor];
        dayView.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)calendar:(JTCalendarManager *)calendar didTouchDayView:(JTCalendarDayView *)dayView {
    _dateSelected = dayView.date;
    
    // Animation for the circleView
    dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
    [UIView transitionWithView:dayView
                      duration:.3
                       options:0
                    animations:^{
                        dayView.circleView.transform = CGAffineTransformIdentity;
                        [_calendarManager reload];
                    } completion:nil];
    
    
    // Load the previous or next page if touch a day from another month
    
    if(![_calendarManager.dateHelper date:_calendarContentView.date isTheSameMonthThan:dayView.date]){
        if([_calendarContentView.date compare:dayView.date] == NSOrderedAscending){
            [_calendarContentView loadNextPageWithAnimation];
        }
        else{
            [_calendarContentView loadPreviousPageWithAnimation];
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MMM yyyy"];
    NSString *dateString = [formatter stringFromDate:_dateSelected];
    
    if (_fromDate == nil) {
        _titleViewLeft.text = [NSString stringWithFormat:@"From date\n%@", dateString];
        
    } else {
        _titleViewRight.text = [NSString stringWithFormat:@"To date\n%@", dateString];
    }
    
}

#pragma mark- Actions

- (void) show {
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    self.frame = mainWindow.frame;
    [mainWindow addSubview:self];
    
    if (_calendarManager == nil) {
        [self initCalendar];
    }
    
    contentView.center = CGPointMake(self.center.x, self.center.y + self.frame.size.height);
    
    [UIView animateWithDuration:TTCalendarAnimationDuration
                          delay:0
         usingSpringWithDamping:0.7f
          initialSpringVelocity:3.0f
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         contentView.center = self.center;
                         NSLog(@"Main View = %@", NSStringFromCGRect(self.frame));
                         NSLog(@"contentView.frame = %@", NSStringFromCGRect(contentView.frame));
                     } completion:^(BOOL finished) {}
     ];
}

- (void) hide {
    [UIView animateWithDuration:TTCalendarAnimationDuration
                          delay:0
         usingSpringWithDamping:0.7f
          initialSpringVelocity:3.0f
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         contentView.center = CGPointMake(self.center.x, self.center.y + self.frame.size.height);
                     }completion:^(BOOL finished) {
                     }];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(finished){
            [self removeFromSuperview];
        }
    }];
    
}

- (IBAction)ontouchConfirm:(id)sender {
    if (_dateSelected != nil) {
        
        if (_fromDate == nil) {
            _fromDate = _dateSelected;
            [_calendarManager reload];
            
        } else {
            _toDate = _dateSelected;
            
            [self.delegate TTCalendarDidSelectWithFromDate:_fromDate toDate:_toDate];
            [self hide];
        }
    }
}

- (IBAction)ontouchCancel:(id)sender {
    [self hide];
}
@end

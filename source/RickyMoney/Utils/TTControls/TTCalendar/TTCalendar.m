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
    NSDate *_dateSelected, *_previousSelected;
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

- (instancetype) initCalendarWithTitle:(NSString*)  title andConfirmButton:(NSString*) buttonTitle {
    self = [super init];
    
    if (self) {
        self = [self initializeSubviews];
    }
    
    _titleView.text = title;
    [_confirmButton setTitle:buttonTitle forState:UIControlStateNormal];
    
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
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

#pragma mark- JTCalendar delegate
// Exemple of implementation of prepareDayView method
// Used to customize the appearance of dayView
- (void)calendar:(JTCalendarManager *)calendar prepareDayView:(JTCalendarDayView *)dayView
{
    dayView.hidden = NO;
    
    // Hide if from another month
    if([dayView isFromAnotherMonth]){
        dayView.hidden = YES;
    }
    // previous selected date
    else if (_previousSelected && [_calendarManager.dateHelper date:_previousSelected isTheSameDayThan:dayView.date]){
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
}

#pragma mark- Actions

- (void) show {
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    self.frame = mainWindow.frame;
    [mainWindow addSubview:self];
    
    if (_calendarManager == nil) {
        [self initCalendar];
    }
    
    CGRect frame = contentView.frame;
    frame.origin.y = self.frame.size.height;
    contentView.frame = frame;
    
    [UIView animateWithDuration:TTCalendarAnimationDuration
                          delay:0
         usingSpringWithDamping:0.7f
          initialSpringVelocity:3.0f
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         contentView.center = self.center;
                         NSLog(@"Main View = %@", NSStringFromCGRect(self.frame));
                         NSLog(@"contentView.frame = %@", NSStringFromCGRect(contentView.frame));
                     } completion:^(BOOL finished) {
                         
                     }];
    
    
    //    [UIView animateWithDuration:0.3f animations:^{
    //        contentView.alpha = 1.0f;
    //    }];
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
        _previousSelected = _dateSelected;
        [_calendarManager reload];
        
        // call delegate of TTCalendar
        [self.delegate TTCalendar:self didSelectDate:_dateSelected];
    }
}


@end

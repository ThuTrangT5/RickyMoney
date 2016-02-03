//
//  RMCalendar.h
//  RickyMoney
//
//  Created by Thu Trang on 1/11/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@class RMCalendar;

@protocol RMCalendarDelegate <NSObject>
@optional
- (void) RMCalendar:(RMCalendar*) calendar didSelectDate:(NSDate*) selectedDate;
@end


@interface RMCalendar : UIView <JTCalendarDelegate>

// calendar
@property (strong, nonatomic) JTCalendarManager *calendarManager;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTVerticalCalendarView *calendarContentView;
@property (weak, nonatomic) IBOutlet UILabel *titleView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

// delegate
@property (nonatomic, weak) id<RMCalendarDelegate> delegate;

- (instancetype) initCalendarWithTitle:(NSString*)  title andConfirmButton:(NSString*) buttonTitle;

- (void) show;
- (void) hide;

@end

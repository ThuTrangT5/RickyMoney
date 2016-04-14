//
//  TTCalendar.h
//  RickyMoney
//
//  Created by Thu Trang on 1/11/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTCalendar.h"

@class TTCalendar;

@protocol TTCalendarDelegate <NSObject>
@optional
- (void) TTCalendarDidSelectWithFromDate:(NSDate *) fromDate toDate:(NSDate*) toDate;
@end


@interface TTCalendar : UIView <JTCalendarDelegate>

// calendar
@property (strong, nonatomic) JTCalendarManager *calendarManager;
@property (weak, nonatomic) IBOutlet JTCalendarMenuView *calendarMenuView;
@property (weak, nonatomic) IBOutlet JTVerticalCalendarView *calendarContentView;
@property (weak, nonatomic) IBOutlet UILabel *titleViewLeft;
@property (weak, nonatomic) IBOutlet UILabel *titleViewRight;

// delegate
@property (nonatomic, weak) id<TTCalendarDelegate> delegate;

//- (instancetype) initCalendarWithTitle:(NSString*)  title andConfirmButton:(NSString*) buttonTitle;

- (void) show;
- (void) hide;

@end

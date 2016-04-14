//
//  TTAlertView.h
//  RickyMoney
//
//  Created by Thu Trang on 4/11/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTAlertView : UIView

/**
 *  Color of interface elements
 */
@property (nonatomic, strong) UIColor *mainColor;

- (instancetype) initWithTitle:(NSString*) title andMessage:(NSString*) message;
- (instancetype) initWithTitle:(NSString*) title andErrorMessage:(NSString*) message;

- (void) show;

@end

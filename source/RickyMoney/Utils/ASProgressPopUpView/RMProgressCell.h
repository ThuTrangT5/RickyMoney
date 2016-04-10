//
//  RMProgressCell.h
//  RickyMoney
//
//  Created by Thu Trang on 4/10/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASProgressPopUpView.h"

@interface RMProgressCell : UITableViewCell <ASProgressPopUpViewDelegate, ASProgressPopUpViewDataSource>

- (void) setProgressValue:(float) currentValue maxValue:(float) maxValue;

@end

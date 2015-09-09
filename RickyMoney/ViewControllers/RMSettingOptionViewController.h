//
//  RMSettingOptionViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/7/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMConstant.h"

@protocol RMSettingOptionDelegate <NSObject>

@required
- (void) settingOption:(SettingOptions) settingOption DidSelectedWithName:(NSString*) optionName andOptionId:(NSString*) optionId;

@end

@interface RMSettingOptionViewController : UITableViewController

@property (nonatomic) SettingOptions option;
@property (strong, nonatomic) NSArray *optionData;
@property (nonatomic, assign) id<RMSettingOptionDelegate> delegate;

@end

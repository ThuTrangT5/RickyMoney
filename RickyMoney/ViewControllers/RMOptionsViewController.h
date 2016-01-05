//
//  RMOptionsViewController.h
//  RickyMoney
//
//  Created by Adelphatech on 9/7/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMConstant.h"

@protocol RMOptionsDelegate <NSObject>
- (void) optionView:(OptionTypes) option DoneWithSelectedData:(NSDictionary*) selectedData;
@end

@interface RMOptionsViewController : UITableViewController

@property (nonatomic) OptionTypes option;
@property (strong, nonatomic) NSArray *optionData;
@property (nonatomic, assign) id<RMOptionsDelegate> delegate;

- (IBAction)ontouchSaveButton:(id)sender;

@end

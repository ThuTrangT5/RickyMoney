//
//  RMOptionsViewController.h
//  RickyMoney
//
//  Created by Thu Trang on 4/3/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMConstant.h"

@protocol RMOptionsDelegate <NSObject>
- (void) optionViewsDoneWithSelectedData:(id) selectedData;
@end

@interface RMOptionsViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic) OptionTypes option;
@property (nonatomic, assign) id<RMOptionsDelegate> delegate;
@property (strong, nonatomic) NSArray *optionData;

@end

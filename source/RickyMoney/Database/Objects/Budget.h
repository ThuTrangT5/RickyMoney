//
//  Budget.h
//  RickyMoney
//
//  Created by Thu Trang on 4/8/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Budget : NSObject
// (userId text, categoryId text, budget real, PRIMARY KEY (userId, categoryId))

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *categoryId, *categoryName, *categoryIcon;
@property (nonatomic) float budget;

@end

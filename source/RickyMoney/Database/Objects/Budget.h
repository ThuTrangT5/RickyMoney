//
//  Budget.h
//  RickyMoney
//
//  Created by Thu Trang on 4/8/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Budget : NSObject
//(objectId text primary key, userId text, categoryId text, budget real, dateUnit text)

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *categoryId;
@property (nonatomic) float budget;
@property (strong, nonatomic) NSString *dateUnit;

@end

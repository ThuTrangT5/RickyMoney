//
//  Transaction.h
//  RickyMoney
//
//  Created by Thu Trang on 4/8/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transaction : NSObject

// (objectId text primary key, userId text, categoryId text, item text, amount real, notes text, date text, type integer)
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *categoryId;
@property (strong, nonatomic) NSString *item;
@property (nonatomic) float amount;
@property (strong, nonatomic) NSString *notes;
@property (strong, nonatomic) NSString *date;
@property (nonatomic) int type;

@end

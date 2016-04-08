//
//  Currency.h
//  RickyMoney
//
//  Created by Thu Trang on 4/8/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Currency : NSObject
// (objectId text primary key, name text, symbol text, image text

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *symbol;
@property (strong, nonatomic) NSString *image;

@end

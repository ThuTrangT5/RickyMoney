//
//  Category.h
//  RickyMoney
//
//  Created by Thu Trang on 4/8/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Category : NSObject
// (objectId text primary key, vnName text, enName text, icon text)

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *vnName;
@property (strong, nonatomic) NSString *enName;
@property (strong, nonatomic) NSString *icon;

@end

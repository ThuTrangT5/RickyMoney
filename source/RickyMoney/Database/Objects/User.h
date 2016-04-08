//
//  User.h
//  RickyMoney
//
//  Created by Thu Trang on 4/7/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
// (objectId text primary key, email text, password text, currencyId text, avatar text, passcode text)

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *passcode;
@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSString *currencyId;

@end

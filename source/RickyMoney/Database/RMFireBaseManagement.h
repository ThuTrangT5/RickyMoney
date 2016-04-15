//
//  RMFireBaseManagement.h
//  RickyMoney
//
//  Created by Thu Trang on 4/15/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface RMFireBaseManagement : NSObject

+ (void) loginWithEmail:(NSString *) email andPassword:(NSString*) password successBlock: (void (^)(NSString *)) block;
+ (void) signupWithEmail:(NSString *) email andPassword:(NSString*) password successBlock: (void (^)(NSString *)) block;

+ (void) getUserDetail:(NSString*) userId successBlock: (void (^)(User *)) block;

@end

//
//  RMFireBaseManagement.h
//  RickyMoney
//
//  Created by Thu Trang on 4/15/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "User.h"

@interface RMFireBaseManagement : NSObject

+ (void) loginWithEmail:(NSString *) email andPassword:(NSString*) password successBlock: (void (^)(NSString *)) block;
+ (void) signupWithEmail:(NSString *) email andPassword:(NSString*) password successBlock: (void (^)(NSString *)) block;
+ (void) resetPasswordForUser:(NSString*) email;

+ (void) changPasswordForUser:(NSString*) email formOld:(NSString*) oldPass toNew:(NSString*) newPass successBlock:(void (^) (BOOL isSuccess)) block;
+ (void) updateCurrency:(NSString*) newCurrencyId forCurrentUserWithSuccessBlock: (void (^)(BOOL)) block;
+ (void) updateAvatar:(UIImage*) newAvatar forCurrentUserWithSuccessBlock: (void (^)(BOOL)) block;
+ (void) updatePasscode:(NSString*) passcode forCurrentUserWithSuccessBlock: (void (^)(BOOL)) block;

+ (void) getCurrentUserDetailWithSuccessBlock: (void (^)(User *)) block;

+ (void) getRemoteData;

@end

//
//  RMFireBaseManagement.m
//  RickyMoney
//
//  Created by Thu Trang on 4/15/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import "RMFireBaseManagement.h"
#import <Firebase/Firebase.h>
#import "RMConstant.h"
#import "TTAlertView.h"
#import "RMDataManagement.h"

static Firebase *myRootRef = nil;

#define NO_INTERNET_ERROR @"The Internet connection appears to be offline."

@implementation RMFireBaseManagement

+ (Firebase*) RMRoofRef {
    if (myRootRef == nil) {
        myRootRef = [[Firebase alloc] initWithUrl: RM_FIREBASE_URL];
    }
    
    return myRootRef;
}

+ (void) loginWithEmail:(NSString *) email andPassword:(NSString*) password successBlock: (void (^)(NSString *)) block {
    Firebase *root = [self RMRoofRef];
    [root authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            NSString *errorMessage = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
            
            if ([errorMessage containsString: NO_INTERNET_ERROR]) {
                // login Offline
                NSString *userId = [[RMDataManagement getSharedInstance] loginWithEmail:email andPassword:password];
                if (userId == nil) {
                    TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Login Error" andErrorMessage: @"Your email or password is not correct."];
                    [alert show];
                    
                } else if (block != nil) {
                    block(userId);
                }
            } else {
                
                TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Login Error" andErrorMessage: errorMessage];
                [alert show];
            }
            
        } else {
            [[RMDataManagement getSharedInstance] createNewUserWithEmail:email password:password andUserId:authData.uid];
            
            if (block != nil) {
                block(authData.uid);
            }
        }
    }];
}

+ (void) signupWithEmail:(NSString *) email andPassword:(NSString*) password successBlock: (void (^)(NSString *)) block {
    Firebase *root = [self RMRoofRef];
    [root createUser:email password:password withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
        if (error) {
            // There was an error creating the account
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Sign Up Error"
                                                    andErrorMessage:[error.userInfo valueForKey:NSLocalizedDescriptionKey]];
            [alert show];
            
        } else {
            NSString *uid = [result objectForKey:@"uid"];
            NSLog(@"Successfully created user account FIREBASE with uid: %@", uid);
            [self setDefaultInfoForUser:uid];
            [[RMDataManagement getSharedInstance] createNewUserWithEmail:email password:password andUserId:uid];
            
            if (block != nil) {
                block(uid);
            }
        }
    }];
}

+ (void) setDefaultInfoForUser:(NSString*) userId {
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:@"avatar-base64-data", @"avatar", @"RMCurrency_01", @"currencyId", nil];
    NSDictionary *passcode = [[NSDictionary alloc] initWithObjectsAndKeys:@"no-passcode", currentDeviceId, nil];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys: info, @"info", passcode, @"passcode", nil];
    
    Firebase *root = [self RMRoofRef];
    NSString *userPath = [NSString stringWithFormat:@"users/%@", userId];
    Firebase *usersRef = [root childByAppendingPath: userPath];
    [usersRef setValue:userInfo];
}

+(void) getUserDetail:(NSString *)userId successBlock:(void (^)(User *))block {
    Firebase *root = [self RMRoofRef];
    NSString *userPath = [NSString stringWithFormat:@"users/%@/info", userId];
    Firebase *usersRef = [root childByAppendingPath: userPath];
    
    [usersRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        if ( block != nil) {
            NSDictionary *userDic = (NSDictionary*)snapshot.value;
            User *user = [[User alloc] init];
            user.objectId = userId;
            user.avatar = [userDic valueForKey:@"avatar"];
            
            block(user);
        }
    }];
}


@end

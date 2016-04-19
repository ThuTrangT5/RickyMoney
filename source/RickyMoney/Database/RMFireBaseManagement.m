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
#import "Currency.h"
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>

static Firebase *myRootRef = nil;
static DGActivityIndicatorView *activityIndicatorView = nil;

#define NO_INTERNET_ERROR @"The Internet connection appears to be offline."
#define ACTIVITY_INDICATOR_TAG 999

@implementation RMFireBaseManagement

+ (void) showWaiting {
    if (activityIndicatorView != nil) {
        [self closeWaiting];
    }
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce tintColor:RM_COLOR size:100];
    activityIndicatorView.frame = topController.view.bounds;
    activityIndicatorView.center = topController.view.center;
    activityIndicatorView.tag = ACTIVITY_INDICATOR_TAG;
    [topController.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
}

+ (void) closeWaiting {
    [activityIndicatorView stopAnimating];
    [activityIndicatorView removeFromSuperview];
    activityIndicatorView = nil;
}

+ (Firebase*) RMRoofRef {
    if (myRootRef == nil) {
        myRootRef = [[Firebase alloc] initWithUrl: RM_FIREBASE_URL];
    }
    
    return myRootRef;
}

+ (void) loginWithEmail:(NSString *) email andPassword:(NSString*) password successBlock: (void (^)(NSString *)) block {
    [self showWaiting];
    
    Firebase *root = [self RMRoofRef];
    [root authUser:email password:password withCompletionBlock:^(NSError *error, FAuthData *authData) {
        [self closeWaiting];
        
        if (error) {
            NSString *errorMessage = [error.userInfo valueForKey:NSLocalizedDescriptionKey];
            if (error.code == FAuthenticationErrorNetworkError) {
                // login Offline
                NSString *userId = [[RMDataManagement getSharedInstance] loginWithEmail:email andPassword:password];
                if (userId == nil) {
                    TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Login Error" andErrorMessage: @"Your email or password is not correct."];
                    [alert show];
                } else if (block != nil) {
                    block(userId);
                }
                
            } else {
                
                // an error occurred while attempting login
                switch(error.code) {
                    case FAuthenticationErrorUserDoesNotExist:
                        errorMessage = @"The user with this email does not exist.";
                        break;
                    case FAuthenticationErrorInvalidEmail:
                        errorMessage = @"This email is invalid.";
                        break;
                    case FAuthenticationErrorInvalidPassword:
                        errorMessage = @"This password is invalid.";
                        break;
                    default:
                        break;
                }
                
                TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Login Error" andErrorMessage: errorMessage];
                [alert show];
            }
            
        } else {
            
            [[NSUserDefaults standardUserDefaults] setValue:authData.uid forKey:CURRENT_USER_ID];
            
            if (block!= nil) {
                block(authData.uid);
            }
            
//            [self getCurrentUserDetailWithSuccessBlock:^(User *user) {
//                user.password = password;
//                [[RMDataManagement getSharedInstance] createNewUserWithInfo:user];
//                
//                if (block != nil) {
//                    block(authData.uid);
//                }
//            }];
            
        }
    }];
}

+ (void) signupWithEmail:(NSString *) email andPassword:(NSString*) password successBlock: (void (^)(NSString *)) block {
    [self showWaiting];
    
    Firebase *root = [self RMRoofRef];
    [root createUser:email password:password withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
        [self closeWaiting];
        
        if (error) {
            // There was an error creating the account
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Sign Up Error"
                                                    andErrorMessage:[error.userInfo valueForKey:NSLocalizedDescriptionKey]];
            [alert show];
            
        } else {
            NSString *uid = [result objectForKey:@"uid"];
            
            NSLog(@"Successfully created user account FIREBASE with uid: %@", uid);
            [self setDefaultInfoForUser:uid withEmail:email];
            
            User *newUser = [[User alloc] init];
            newUser.objectId = uid;
            newUser.email = email;
            newUser.password = password;
            
            [[RMDataManagement getSharedInstance] createNewUserWithInfo:newUser];
            
            [[NSUserDefaults standardUserDefaults] setValue:uid forKey:CURRENT_USER_ID];
            
            if (block != nil) {
                block(uid);
            }
        }
    }];
}

+ (void) resetPasswordForUser:(NSString*) email {
    [self showWaiting];
    Firebase *root = [self RMRoofRef];
    
    [root resetPasswordForUser:email withCompletionBlock:^(NSError *error) {
        [self closeWaiting];
        
        NSString *message = nil;
        if (error) {
            switch (error.code) {
                case FAuthenticationErrorInvalidEmail:
                case FAuthenticationErrorUserDoesNotExist:
                    message = @"The specified user account does not exist.";
                    break;
                    
                default:
                    message = [NSString stringWithFormat:@"Error resetting password: %@", error.description];
                    break;
            }
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Reset Password" andErrorMessage: message];
            [alert show];
            
        } else {
            message = @"Password reset email sent successfully.\nPlease check your email.";
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Reset Password" andMessage: message];
            [alert show];
        }
    }];
}

+ (void) changPasswordForUser:(NSString*) email formOld:(NSString*) oldPass toNew:(NSString*) newPass successBlock:(void (^) (BOOL isSuccess)) block {
    [self showWaiting];
    
    Firebase *root = [self RMRoofRef];
    [root changePasswordForUser:email fromOld:oldPass toNew:newPass withCompletionBlock:^(NSError *error) {
        [self closeWaiting];
        
        if (error) {
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Sign Up Error"
                                                    andErrorMessage:[error.userInfo valueForKey:NSLocalizedDescriptionKey]];
            [alert show];
            
        } else {
            
            // update password for user offline
            NSString *userId = [[RMDataManagement getSharedInstance] getCurrentUserId];
            [[RMDataManagement getSharedInstance] updatePassword:newPass forUser:userId];
            
            if (block != nil) {
                block(YES);
            }
        }
    }];
}

+ (void) setDefaultInfoForUser:(NSString*) userId withEmail:(NSString *) email {
    UIDevice *device = [UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];
    
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys: email, @"email", @"RMCurrency_01", @"currencyId", nil];
    NSDictionary *passcode = [[NSDictionary alloc] initWithObjectsAndKeys:@"", currentDeviceId, nil];
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys: info, @"info", passcode, @"passcode", nil];
    
    Firebase *root = [self RMRoofRef];
    NSString *userPath = [NSString stringWithFormat:@"users/%@", userId];
    Firebase *usersRef = [root childByAppendingPath: userPath];
    [usersRef setValue:userInfo];
}

+ (void) updateCurrency:(NSString*) newCurrencyId forCurrentUserWithSuccessBlock: (void (^)(BOOL)) block {
    [self showWaiting];
    
    NSString *userId = [[RMDataManagement getSharedInstance] getCurrentUserId];
    
    Firebase *root = [self RMRoofRef];
    NSString *userCurrencyPath = [NSString stringWithFormat: @"users/%@/info/currencyId", userId];
    Firebase *userRef = [root childByAppendingPath:userCurrencyPath];
    
    [userRef setValue:newCurrencyId withCompletionBlock:^(NSError *error, Firebase *ref) {
        [self closeWaiting];
        
        if (error != nil) {
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Update Currency" andErrorMessage: error.description];
            [alert show];
        } else {
            // update offline data
            [[RMDataManagement getSharedInstance] updateCurrency:newCurrencyId forUser:userId];
            
            if (block != nil) {
                block(TRUE);
            }
        }
    }];
}

+ (void) updateAvatar:(UIImage*) newAvatar forCurrentUserWithSuccessBlock: (void (^)(BOOL)) block {
    [self showWaiting];
    
    NSString *imageString = [RMDataManagement encodeToBase64String:newAvatar];
    NSString *userId = [[RMDataManagement getSharedInstance] getCurrentUserId];
    
    Firebase *root = [self RMRoofRef];
    NSString *path = [NSString stringWithFormat: @"users/%@/info/avatar", userId];
    Firebase *childRef = [root childByAppendingPath:path];
    
    [childRef setValue:imageString withCompletionBlock:^(NSError *error, Firebase *ref) {
        [self closeWaiting];
        
        if (error != nil) {
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"Update Avatar" andErrorMessage:[error.userInfo valueForKey:NSLocalizedDescriptionKey]];
            [alert show];
            
        } else {
            [[RMDataManagement getSharedInstance] updateAvatar:newAvatar forUser:userId];
            
            if (block != nil) {
                block(TRUE);
            }
        }
    }];
}

+ (void)updatePasscode:(NSString *)passcode forCurrentUserWithSuccessBlock:(void (^)(BOOL))block {
    NSString *userId = [[RMDataManagement getSharedInstance] getCurrentUserId];
    UIDevice *device = [UIDevice currentDevice];
    NSString  *uuid = [[device identifierForVendor]UUIDString];
    
    Firebase *root = [self RMRoofRef];
    NSString *passcodePath = [NSString stringWithFormat: @"users/%@/passcode/%@", userId, uuid];
    Firebase *userRef = [root childByAppendingPath:passcodePath];
    
    [userRef setValue:passcode withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error != nil) {
            
            NSLog(@"Update Passcode FireBase Error : %@", error.description);
            
        }
        BOOL resultOff = [[RMDataManagement getSharedInstance] updatePasscode:passcode forUser:userId];
        
        if (block != nil) {
            block(resultOff);
        }
    }];
}


// get account detail to store in local database
+ (void) getCurrentUserDetailWithSuccessBlock: (void (^)(User *)) block {
    
    NSString *userId = [[RMDataManagement getSharedInstance] getCurrentUserId];
    
    Firebase *root = [self RMRoofRef];
    NSString *userPath = [NSString stringWithFormat:@"users/%@/info", userId];
    Firebase *usersRef = [root childByAppendingPath: userPath];
    
    [usersRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        
        User *user = nil;
        if (snapshot == nil) {
            // get user infor offline
            user = [[RMDataManagement getSharedInstance] getCurrentUserDetail];
            
        } else if ( block != nil) {
            NSDictionary *userDic = (NSDictionary*)snapshot.value;
            user = [[User alloc] init];
            user.objectId = userId;
            user.avatar = [userDic valueForKey:@"avatar"];
            user.email =  [userDic valueForKey:@"email"];
            user.currencyId = [userDic valueForKey:@"currenyId"];
        }
        
        if (user == nil) {
            TTAlertView *alert = [[TTAlertView alloc] initWithTitle:@"User" andErrorMessage:@"Can not find information about this user."];
            [alert show];
        } else if (block != nil) {
            block(user);
        }
    }];
}

+ (void) getRemoteData {
    Firebase *root = [self RMRoofRef];
    
    Firebase *categoryRef = [root childByAppendingPath:@"category"];
    [categoryRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [[RMDataManagement getSharedInstance] updateCategoryWithData:snapshot.value];
    }];
    
    Firebase *currencyRef = [root childByAppendingPath:@"currency"];
    [currencyRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        [[RMDataManagement getSharedInstance] updateCurrencyWithData:snapshot.value];
    }];
}

@end

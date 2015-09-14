//
//  RMParseRequestHandler.m
//  RickyMoney
//
//  Created by Adelphatech on 9/6/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMParseRequestHandler.h"
#import "AppDelegate.h"


@implementation RMParseRequestHandler

+ (void)getObjectById:(NSString *)objectId inClass:(NSString *)className withSuccessBlock:(PFObjectResultBlock)block {
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query getObjectInBackgroundWithId:objectId block:block];
}

+ (void)getDataByQuery:(PFQuery *)query withSuccessBlock:(PFArrayResultBlock)block {
    [query findObjectsInBackgroundWithBlock: ^(NSArray* objects, NSError* error) {
        if (error != nil) {
            [self handleParseError:error];
        } else if (block != nil) {
            block(objects, error);
        }
    }];
}

+ (void)callFunction:(NSString *)functionName withSuccessBlock:(PFArrayResultBlock)block {
    
}

#pragma mark- Parse Error handling

+ (void)handleParseError:(NSError *)error {
    if (![error.domain isEqualToString:PFParseErrorDomain]) {
        return;
    }
    
    switch (error.code) {
        case kPFErrorInvalidSessionToken: {
            [self _handleInvalidSessionTokenError];
            break;
        }
        case kPFErrorConnectionFailed:{
            NSLog(@"ERROR CODE == 100");
            [self _handleInvalidSessionTokenError];
            break;
        }
        default: {
            // Other Parse API Errors that you want to explicitly handle.
            NSLog(@"error: %@", error.description);
//            [SnapostUtils showErrorWithMessage:error.description andCompletionCallback:nil];
            break;
        }
    }
}

+ (void)_handleInvalidSessionTokenError {
    //--------------------------------------
    // Option 1: Show a message asking the user to log out and log back in.
    //--------------------------------------
    // If the user needs to finish what they were doing, they have the opportunity to do so.
    //
    // UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Session"
    //                                                     message:@"Session is no longer valid, please log out and log in again."
    //                                                    delegate:self
    //                                           cancelButtonTitle:@"Not Now"
    //                                           otherButtonTitles:@"OK"];
    // [alertView show];
    
    //--------------------------------------
    // Option #2: Show login screen so user can re-authenticate.
    //--------------------------------------
    // You may want this if the logout button is inaccessible in the UI.
    //
    NSLog(@"Session is no longer valid, please log out and log in again.");
//    [SnapostUtils showErrorWithMessage:@"Session is no longer valid, please log out and log in again." andCompletionCallback:^{
//        [PFUser logOut];
//        [[[[UIApplication sharedApplication] keyWindow] rootViewController] dismissViewControllerAnimated:YES completion:nil];
//    }];
    //     UIViewController *presentingViewController = [[UIApplication sharedApplication].keyWindow.rootViewController;
    // PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    // [presentingViewController presentViewController:logInViewController animated:YES completion:nil];
}
@end

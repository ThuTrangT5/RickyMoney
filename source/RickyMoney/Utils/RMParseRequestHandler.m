//
//  RMParseRequestHandler.m
//  RickyMoney
//
//  Created by Adelphatech on 9/6/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import "RMParseRequestHandler.h"
#import "AppDelegate.h"
#import "RMConstant.h"
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>


static DGActivityIndicatorView *waitingView;

@implementation RMParseRequestHandler

#pragma mark- Waiting view

+ (UIView*) currentMainView {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController.view;
}

+ (DGActivityIndicatorView *) createWaitingView {
    
    DGActivityIndicatorView *activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:DGActivityIndicatorAnimationTypeDoubleBounce
                                                                                         tintColor: RM_COLOR
                                                                                              size:150.0f];
    
    UIView *mainView = [RMParseRequestHandler currentMainView];
    activityIndicatorView.frame = mainView.frame;
    [mainView addSubview:activityIndicatorView];
    
    return activityIndicatorView;
}

+ (void) showWaitingView {
    if (waitingView != nil) {
        [RMParseRequestHandler closeWaitingView];
    }
    
    waitingView = [RMParseRequestHandler createWaitingView];
    [waitingView startAnimating];
}

+ (void)closeWaitingView {
    [waitingView stopAnimating];
    [waitingView removeFromSuperview];
    waitingView = nil;
}

+ (void)showSuccessWithMessage:(NSString *)message andCompletionCallback: (void (^)())completionBlock {
    [RMParseRequestHandler closeWaitingView];
    
    if (message != nil) {
        //???
        
    } else if (completionBlock != nil) {
        completionBlock();
    }
    
}

+ (void)showErrorWithMessage:(NSString *)message andCompletionCallback: (void (^)())completionBlock {
    
    [RMParseRequestHandler closeWaitingView];
    
    if (message == nil || [message isEqualToString:@""]) {
        message = @"Something wrong happen. Please check again.";
    }
    
    // ??? show alert message here
}

#pragma mark- Queries

+ (void)getObjectById:(NSString *)objectId inClass:(NSString *) className includeFields:(NSArray*) fields withSuccessBlock:(void (^)(id))block {
    [RMParseRequestHandler showWaitingView];
    PFQuery *query = [PFQuery queryWithClassName:className];
    for (NSString *field in fields) {
        [query includeKey:field];
    }
    
    [query getObjectInBackgroundWithId:objectId block:^(PFObject *object, NSError *error){
        [RMParseRequestHandler closeWaitingView];
        
        if (error != nil) {
            [self handleParseError:error];
        } else if (block != nil) {
            block(object);
        }
    }];
}

+ (void)getDataByQuery:(PFQuery *)query withSuccessBlock:(void (^)(NSArray *))block {
    [query findObjectsInBackgroundWithBlock: ^(NSArray* objects, NSError* error) {
        [RMParseRequestHandler closeWaitingView];
        
        if (error != nil) {
            [self handleParseError:error];
        } else if (block != nil) {
            block(objects);
        }
    }];
}

+ (void)callFunction:(NSString *)functionName WithParams:(NSDictionary *)params withSuccessBlock:(void (^)(id))block {
    [PFCloud callFunctionInBackground:functionName withParameters:params block:^(id result, NSError *error) {
        if (error != nil) {
            [RMParseRequestHandler handleParseError:error];
            
        } else {
            [RMParseRequestHandler showSuccessWithMessage:nil andCompletionCallback:nil];
            
            if (block != nil) {
                block(result);
            }
        }
    }];
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

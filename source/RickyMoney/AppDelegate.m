//
//  AppDelegate.m
//  RickyMoney
//
//  Created by Adelphatech on 8/26/15.
//  Copyright © 2015 adelphatech. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "RMConstant.h"
#import "RMPasscodeViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Initialize Parse.
    [Parse setApplicationId:@"RfUxmpN0LZrBjt3ot3nNSEs7mZi8FkH1eXj3xNNq"
                  clientKey:@"pujHteh4ypz1I1KUdJzpSpY5cPnKpElUMflzi0ug"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // check passcode
    NSString *passcode = [[NSUserDefaults standardUserDefaults] valueForKey:CURRENT_PASSCODE];
    if (passcode != nil && passcode.length > 0) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        RMPasscodeViewController *vc = (RMPasscodeViewController*) [mainStoryboard instantiateViewControllerWithIdentifier:PASSCODE_VIEW_STORYBOARD_KEY];
        [vc displayView];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma Login & Logout

- (void) loginSuccess {
    
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^{
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        UIViewController *mainView = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainView"];
                        [self.window.rootViewController presentViewController:mainView animated:NO completion:nil];
                    }
                    completion:nil];
}

- (void) logoutSuccess {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: LOGIN_DATE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: CURRENT_USER_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: CURRENT_PASSCODE];

    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
                    }
                    completion:nil];
}

@end

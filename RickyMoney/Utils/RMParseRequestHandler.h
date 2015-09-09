//
//  RMParseRequestHandler.h
//  RickyMoney
//
//  Created by Adelphatech on 9/6/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/PFObject.h>
#import <Parse/PFQuery.h>
#import <Parse/PFCloud.h>
#import <Parse/PFConstants.h>

@interface RMParseRequestHandler : UIViewController

+ (void) getObjectById:(NSString*) objectId inClass:(NSString*) className withSuccessBlock:(PFObjectResultBlock) block;
+ (void) getDataByQuery:(PFQuery*) query withSuccessBlock: (PFArrayResultBlock) block;
+ (void) callFunction:(NSString*) functionName withSuccessBlock: (PFArrayResultBlock) block;

@end

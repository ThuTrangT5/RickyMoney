//
//  RMParseRequestHandler.h
//  RickyMoney
//
//  Created by Adelphatech on 9/6/15.
//  Copyright (c) 2015 adelphatech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RMConstant.h"

@interface RMParseRequestHandler : UIViewController

+ (void)getObjectById:(NSString *)objectId inClass:(NSString *) className includeFields:(NSArray*) fields withSuccessBlock:(void (^)(id))block;
+ (void) getDataByQuery:(PFQuery*) query withSuccessBlock: (void (^)(NSArray *)) block;
+ (void)callFunction:(NSString *)functionName WithParams:(NSDictionary *)params withSuccessBlock:(void (^)(id))block;

+ (void) getAllTransactionByUser:(NSString*) userId transactionType:(TransactionType) type inCategory:(NSString*) categoryId forPage:(int) page withSuccessBlock: (void (^) (NSArray*)) block;

@end

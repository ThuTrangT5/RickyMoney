//
//  RMDataManagement.h
//  RickyMoney
//
//  Created by Thu Trang on 4/6/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RMObjects.h"
#import "RMConstant.h"

@interface RMDataManagement : NSObject

+ (RMDataManagement*)getSharedInstance;

+ (NSString *)encodeToBase64String:(UIImage *)image;
+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;

- (NSString*) createNewUserWithEmail:(NSString *) email password:(NSString*) password;
- (NSString*) loginWithEmail:(NSString*) email andPassword:(NSString*) password;
- (User*) getCurrentUserDetail;
- (NSString*) getCurrentUserCurrencySymbol;

- (BOOL) updateCurrency:(NSString*) currencyId forUser:(NSString *) userId;
- (BOOL) updateAvatar:(UIImage*) avatar forUser:(NSString*) userId;
- (BOOL) updatePasscode:(NSString*) newPasscode forUser:(NSString*) userId;
- (BOOL) updatePassword:(NSString*) newPassword forUser:(NSString*) userId;

- (NSArray*) getAllCurrency;
- (NSArray*) getAllCategory;

- (NSString*) createNewTransaction:(Transaction*) newTransaction;
- (BOOL) updateTransaction:(Transaction*) updatedTransaction;
- (BOOL) deleteTransaction:(NSString*) transactionId;
- (NSArray*) getTransactionsByPage:(int) page category:(NSString*) categoryId type:(TransactionType) type;
- (Transaction*) getTransactionDetail:(NSString*) transactionId;
- (NSArray*) reviewTransactionFromDate:(NSString*)fromDate toDate:(NSString*) toDate;

- (NSArray*) getAllBudgetsFromDate:(NSString*)fromDate toDate:(NSString*) toDate;
- (BOOL) createNewBudget:(float) budget forCategory:(NSString*) categoryId;
- (NSArray*) getAllBudgetsForEdit;

@end

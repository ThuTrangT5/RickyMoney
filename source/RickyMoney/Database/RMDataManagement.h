//
//  RMDataManagement.h
//  RickyMoney
//
//  Created by Thu Trang on 4/6/16.
//  Copyright © 2016 adelphatech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMDataManagement : NSObject

+(RMDataManagement*)getSharedInstance;
-(BOOL)createDB;

@end

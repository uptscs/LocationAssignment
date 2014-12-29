//
//  StorageManager.h
//  LocationAssignment
//
//  Created by admin on 29/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StorageManager : NSObject

+(NSDate *)getLastSubmitDate;
+(void)saveSubmitDate : (NSDate *)localTimezoneDate;

@end

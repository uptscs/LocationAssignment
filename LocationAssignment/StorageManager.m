//
//  StorageManager.m
//  LocationAssignment
//
//  Created by admin on 29/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "StorageManager.h"

@implementation StorageManager

+(NSDate *)getLastSubmitDate
{
    //Get the last saved date in GMT convert it to local timezone and return
    NSDate *previousSubmitDate = [[NSUserDefaults standardUserDefaults] objectForKey:kPreviousSubmitTimeKey];
    if (previousSubmitDate) {
        NSTimeZone *tz = [NSTimeZone defaultTimeZone];
        NSInteger seconds = [tz secondsFromGMTForDate: previousSubmitDate];
        return [NSDate dateWithTimeInterval: seconds sinceDate: previousSubmitDate];
    }
    return nil;
}

+(void)saveSubmitDate : (NSDate *)localTimezoneDate
{
    //Convert to GMT time zone and then save
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: localTimezoneDate];
    NSDate *dateGMT = [NSDate dateWithTimeInterval: seconds sinceDate: localTimezoneDate];
    [[NSUserDefaults standardUserDefaults] setObject:dateGMT forKey:kPreviousSubmitTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

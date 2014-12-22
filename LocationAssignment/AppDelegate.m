//
//  AppDelegate.m
//  LocationAssignment
//
//  Created by admin on 17/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "WebserviceManager.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[WebserviceManager getInstance] runWithHandler:^(id response) {
        if (![response isKindOfClass:[NSError class]]) {
            NSDate *previousSubmitDate = [NSDate date];
            [self saveSubmitDate:previousSubmitDate];
        } else {
            // Show alert
        }
    }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"Application entered background state.");
    
    // bgTask is instance variable
    NSAssert(self->bgTask == UIBackgroundTaskInvalid, nil);
    
    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [application endBackgroundTask:self->bgTask];
            self->bgTask = UIBackgroundTaskInvalid;
        });
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([application backgroundTimeRemaining] > 1.0) {
            // Start background service synchronously
            [[WebserviceManager getInstance] runWithHandler:^(id response) {
                if (![response isKindOfClass:[NSError class]]) {
                    NSDate *previousSubmitDate = [NSDate date];
                    [self saveSubmitDate:previousSubmitDate];
                } else {
                    // Show alert
                }
            }];
        }
        [application endBackgroundTask:self->bgTask];
        self->bgTask = UIBackgroundTaskInvalid;
    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)saveSubmitDate : (NSDate *)localTimezoneDate
{
    //Convert to GMT time zone and then save
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: localTimezoneDate];
    NSDate *dateGMT = [NSDate dateWithTimeInterval: seconds sinceDate: localTimezoneDate];
    [[NSUserDefaults standardUserDefaults] setObject:dateGMT forKey:kPreviousSubmitTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end

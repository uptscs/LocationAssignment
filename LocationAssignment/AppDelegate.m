//
//  AppDelegate.m
//  LocationAssignment
//
//  Created by admin on 17/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "WebserviceOperation.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
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
            [self submitData];
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
    [self submitData];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)submitData{
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomerNameKey];
    double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:kCustomerLatitude];
    double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:kCustomerLongitude];
    if (nil == userName || userName.length <= 0) {
        return;
    }
    NSDictionary *parameters = @{@"Name":userName,
                                 @"latitude":@(latitude),
                                 @"longitude":@(longitude)};
    [WebserviceOperation runWebservicewithParameters: parameters completionHander :^(WebServiceStatus status, NSString *submitDate, NSError* error){
        if (nil == error) {
            NSDate *date = [NSDate date];
            [StorageManager saveSubmitDate:date];
        }else{
            NSLog(@"Error: %@", error.description);
        }
    }];
}

@end

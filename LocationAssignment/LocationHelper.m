//
//  LocationHelper.m
//  LocationAssignment
//
//  Created by admin on 30/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "LocationHelper.h"

@interface LocationHelper()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

-(void)locationManagerSetup;

@end

@implementation LocationHelper

+(LocationHelper*)sharedInstance {
    static LocationHelper* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedInstance = [[LocationHelper alloc] init];
        [sharedInstance locationManagerSetup];
    });
    return sharedInstance;
}

-(void)locationManagerSetup{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [self.locationManager requestWhenInUseAuthorization];
}

+(void)startUpdatingLocation{
    [[self sharedInstance].locationManager startUpdatingLocation];
}

+(void)stopUpdatingLocation{
    [[self sharedInstance].locationManager stopUpdatingLocation];
}

#pragma mark -
#pragma mark CLLocation manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:kNewCurrentLocationNotificationFound object:self.currentLocation userInfo:nil];
    });

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) {
        NSLog(@"Location update stopped, reason: %@", error.description);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter postNotificationName:kNewCurrentLocationNotificationFound object:self.currentLocation userInfo:nil];
    });
}

@end

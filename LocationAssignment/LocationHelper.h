//
//  LocationHelper.h
//  LocationAssignment
//
//  Created by admin on 30/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLLocation+Strings.h"

@interface LocationHelper : NSObject

@property (nonatomic, strong) CLLocation *currentLocation;

+(void)startUpdatingLocation;
+(void)stopUpdatingLocation;
+(LocationHelper*)sharedInstance;

@end

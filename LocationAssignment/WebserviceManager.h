//
//  WebserviceManager.h
//  LocationAssignment
//
//  Created by admin on 21/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebserviceManager : NSObject

+ (WebserviceManager *)getInstance;
- (void)run;

@end

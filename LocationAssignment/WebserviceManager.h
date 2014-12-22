//
//  WebserviceManager.h
//  LocationAssignment
//
//  Created by admin on 21/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^Handler)(id response);

@interface WebserviceManager : NSObject

+ (WebserviceManager *)getInstance;
- (void)runWithHandler:(Handler)completionHanler;

@end

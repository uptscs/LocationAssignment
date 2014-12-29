//
//  WebserviceOperation.h
//  LocationAssignment
//
//  Created by admin on 24/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkOperation.h"

typedef enum{
    WebServiceStatusFailure = 0,
    WebServiceStatusSuccess
}WebServiceStatus;

typedef void (^WebserviceCompletionHandler)(WebServiceStatus status, NSString *submitDate, NSError* error);


@interface WebserviceOperation : MKNetworkOperation

@property(nonatomic, strong)    MKNetworkEngine *network;
@property(nonatomic, assign)    WebserviceCompletionHandler completionHandler;

+(void)runWebservicewithParameters: (NSDictionary *)parameters completionHander:(WebserviceCompletionHandler)completionHander;
@end

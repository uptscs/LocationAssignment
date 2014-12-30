//
//  WebserviceOperation.m
//  LocationAssignment
//
//  Created by admin on 24/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "WebserviceOperation.h"

static WebserviceOperation *sharedInstance;

@implementation WebserviceOperation

-(id)initOperationForUrl: (NSString *) inUrl withParams:(NSDictionary *)inParams havingHTTPMethod:(NSString *) inHTTPMethod checkTimeout:(BOOL) isTimeoutValid {
    self = [self initWithURLString:inUrl params:inParams httpMethod:inHTTPMethod];
    return self;
}


-(void) operationFailedWithError:(NSError*) error {
    
}

+(void)runWebservicewithParameters: (NSDictionary *)parameters completionHander:(WebserviceCompletionHandler)completionHander;
{
    NSString *userName = [parameters objectForKey:@"Name"];
    double latitude= [[parameters objectForKey:@"latitude"] doubleValue];
    double longitude= [[parameters objectForKey:@"longitude"] doubleValue];
    NSDictionary *headers = @{kContentType : kContentTypeJson, kAcceptEncoding : kGzip};
    NSString *data = [NSString stringWithFormat:@"data=%@ is now at %f/%f", userName, latitude, longitude];

    sharedInstance = [[WebserviceOperation alloc] initWithURLString:kURLEvent params:nil httpMethod:kMethodPOST];
    [sharedInstance setUsername:kUsername password:kPassword basicAuth:YES];
    sharedInstance.network = [[MKNetworkEngine alloc] initWithHostName:nil customHeaderFields:headers];
    
    [sharedInstance setCustomPostDataEncodingHandler:^NSString *(NSDictionary *postDataDict) {
        return data;
    } forType:kContentTypeJson];

    [sharedInstance addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        if([completedOperation.url rangeOfString:kURLEvent].length) {
            if (completedOperation.HTTPStatusCode == kStatusSuccess) {
                NSString *submitDate = [completedOperation.readonlyResponse.allHeaderFields objectForKey:@"Date"];
                completionHander(WebServiceStatusSuccess, submitDate,nil);
            }else{
                NSError *error = [NSError errorWithDomain:@"Fail" code:0 userInfo:@{@"Description": @"Invalid Username and Password"}];
                completionHander(WebServiceStatusFailure, nil,error);
            }
        }else{
            NSError *error = [NSError errorWithDomain:@"Fail" code:0 userInfo:@{@"Description": @"Invalid webservice call"}];
            completionHander(WebServiceStatusFailure, nil,error);
        }
    }errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
            completionHander(WebServiceStatusFailure, nil,error);
     }];
    [sharedInstance.network enqueueOperation:sharedInstance];
}
@end

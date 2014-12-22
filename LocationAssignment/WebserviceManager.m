//
//  WebserviceManager.m
//  LocationAssignment
//
//  Created by admin on 21/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "WebserviceManager.h"
#import "ViewController.h"
#import "AFHTTPRequestOperationManager.h"

#define kURLString      @"http://gentle-tor-1851.herokuapp.com/events"
#define kUserName       @"upendra"
#define kPassword       @"lumbergh21"

#define kSuccessReturnCode 201
/*
 * The singleton instance. To get an instance, use
 * the getInstance function.
 */
static WebserviceManager *instance = NULL;

@implementation WebserviceManager

/**
 * Singleton instance.
 */
+(WebserviceManager *)getInstance {
    @synchronized(self) {
        if (instance == NULL) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

- (void)runWithHandler:(Handler)completionHanler{

    NSString *customerName = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomerNameKey];
    double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:kCustomerLatitude];
    double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:kCustomerLongitude];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:kUsername password:kPassword persistence:NSURLCredentialPersistenceForSession];
    [manager setCredential:credential];
    NSString *postData = [NSString stringWithFormat:@"%@ is now at %f/%f", customerName, latitude, longitude];
    NSDictionary *parameters = @{@"data": postData};
    
    [manager POST:kURLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completionHanler){
                completionHanler(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completionHanler){
                completionHanler(error);
        }

    }];
}

@end

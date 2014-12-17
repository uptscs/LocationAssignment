//
//  ViewController.m
//  LocationAssignment
//
//  Created by admin on 17/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "ViewController.h"
#import "CLLocation+Strings.h"

#define kCustomerNameKey            @"StoredCustomerName"
#define kPreviousSubmitTimeKey      @"PreviousSubmitTime"
#define kDefaultCustomerName        @"John Doe"

@interface ViewController ()<UITextFieldDelegate, CLLocationManagerDelegate>{
    IBOutlet UITextField    *_textfieldCustomerName;
    IBOutlet UILabel        *_labelPreviousSubmitMessage;
    IBOutlet UILabel        *_labelCurrentLocation;
    CLLocationManager       *_locationManager;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSString *customerName = [[NSUserDefaults standardUserDefaults] stringForKey:kCustomerNameKey];
    if (nil != customerName && customerName.length) {
        _textfieldCustomerName.text = customerName;
    }else{
        _textfieldCustomerName.text = kDefaultCustomerName;
    }
    NSString *previousSubmitTime = [self getPreviousSubmitTime];
    _labelPreviousSubmitMessage.text = [NSString stringWithFormat:@"Last submitted %@ ago", previousSubmitTime];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextfield delegate handlers

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self storeTextfieldValue:textField];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark User interaction methods

-(IBAction)submit:(id)sender{
    [_textfieldCustomerName resignFirstResponder];
    //    NSString *customerName = _textfieldCustomerName.text;
    //    double latitude = 1201212.1;
    //    double longitude = 1201212.1;
    //    NSString *postString = [NSString stringWithFormat:@"data = %@ is now at %f/%f", customerName, latitude, longitude];
}

#pragma mark -
#pragma mark Custom methods

-(void)storeTextfieldValue:(UITextField *)textField{
    NSString *customerName = textField.text;
    [[NSUserDefaults standardUserDefaults] setObject:customerName forKey:kCustomerNameKey];
}

-(NSString *)getPreviousSubmitTime{
    return @"9 Minutes";
}


#pragma mark -
#pragma mark CLLocation manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSString *locationDescription = newLocation.localizedCoordinateString;
    _labelCurrentLocation.text = locationDescription;
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocationWithMessage:NSLocalizedString(@"Error", @"Error")];
    }
}


- (void)stopUpdatingLocationWithMessage:(NSString *)state {
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    NSLog(@"Location update stopped, reason: %@", state);
}

@end

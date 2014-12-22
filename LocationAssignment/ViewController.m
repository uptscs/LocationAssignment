//
//  ViewController.m
//  LocationAssignment
//
//  Created by admin on 17/12/14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "ViewController.h"
#import "CLLocation+Strings.h"
#import <Security/Security.h>
#import "AFHTTPRequestOperationManager.h"
#import "WebserviceManager.h"

@interface ViewController ()<UITextFieldDelegate, CLLocationManagerDelegate>{
    IBOutlet UITextField    *_textfieldCustomerName;
    IBOutlet UILabel        *_labelPreviousSubmitMessage;
    IBOutlet UILabel        *_labelCurrentLocation;
    
    CLLocationManager       *_locationManager;

    NSDate      *_previousSubmitDate;
    NSTimer     *_timer;

    BOOL        _isTimersetforMinutes;
    double      latitude;
    double      longitude;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    _previousSubmitDate = [self getLastSubmitDate];
    if (_previousSubmitDate) {
        [self startTimer:1.0];
    }
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
    _previousSubmitDate = [NSDate date];
    _labelPreviousSubmitMessage.text = [self getDateMessage:0];
    [[WebserviceManager getInstance] runWithHandler:^(id response) {
        if (![response isKindOfClass:[NSError class]]) {
            _previousSubmitDate = [NSDate date];
            [self saveSubmitDate:_previousSubmitDate];
            [self startTimer:1.0];
        } else {
            // Show alert
        }
    }];
}

#pragma mark -
#pragma mark Custom methods

-(void)startTimer : (NSTimeInterval)timeInterval{
    if (timeInterval <= 1.0) {
        _isTimersetforMinutes = NO;
    }
    if (_timer) {
        [_timer invalidate];
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                              target:self
                                            selector:@selector(updateSubmitTimeMessage:)
                                            userInfo:nil
                                             repeats:YES];
}

-(void)storeTextfieldValue:(UITextField *)textField{
    NSString *customerName = textField.text;
    [[NSUserDefaults standardUserDefaults] setObject:customerName forKey:kCustomerNameKey];
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

-(NSDate *)getLastSubmitDate
{
    //Get the last saved date in GMT convert it to local timezone and return
    NSDate *previousSubmitDate = [[NSUserDefaults standardUserDefaults] objectForKey:kPreviousSubmitTimeKey];
    if (previousSubmitDate) {
        NSTimeZone *tz = [NSTimeZone defaultTimeZone];
        NSInteger seconds = [tz secondsFromGMTForDate: previousSubmitDate];
        return [NSDate dateWithTimeInterval: seconds sinceDate: previousSubmitDate];
    }
    return nil;
}

#pragma mark -
#pragma mark Helper methods

-(void)updateSubmitTimeMessage : (NSTimer *)timer{
    NSTimeInterval timeDifference = [_previousSubmitDate timeIntervalSinceNow];
    _labelPreviousSubmitMessage.text = [self getDateMessage:-timeDifference];
}

-(NSString *)getDateMessage : (NSTimeInterval)interval{
    if(!interval){
        return @"Just submitted";
    }else if(interval < 60.0){
        NSInteger seconds = interval;
        NSString *secondString = (seconds <= 1 ? @"second": @"seconds");
        return [NSString stringWithFormat:@"Last submitted %li %@ before", seconds, secondString];
    }else if(interval < 3600.0){
        //Minutes
        if(!_isTimersetforMinutes){
            [self startTimer:60.0];
            _isTimersetforMinutes = YES;
        }
        int minutes = interval / 60;
        NSString *minuteString = (minutes == 1 ? @"minute": @"minutes");
        return [NSString stringWithFormat:@"Last submitted %i %@ before", minutes, minuteString];
    }else if(interval >= 3600.0){
        //Hours
        int hour = interval / 3600;
        NSString *hourString = (hour == 1 ? @"hour": @"hours");
        return [NSString stringWithFormat:@"Last submitted %i %@ before", hour, hourString];
    }else{
        //Days
        int day = interval / (3600 * 60);
        NSString *dayString = (day == 1 ? @"day": @"days");
        return [NSString stringWithFormat:@"Last submitted %i %@ before", day, dayString];
    }
    return @"No submission done";
}

#pragma mark -
#pragma mark CLLocation manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    latitude = newLocation.coordinate.latitude;
    longitude = newLocation.coordinate.longitude;
    [[NSUserDefaults standardUserDefaults] setDouble:latitude forKey:kCustomerLatitude];
    [[NSUserDefaults standardUserDefaults] setDouble:longitude forKey:kCustomerLongitude];
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

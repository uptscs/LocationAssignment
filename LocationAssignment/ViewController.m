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
#import "WebserviceOperation.h"
#import "LocationHelper.h"

@interface ViewController ()<UITextFieldDelegate>{
    IBOutlet UITextField    *_textfieldCustomerName;
    IBOutlet UILabel        *_labelPreviousSubmitMessage;
    IBOutlet UILabel        *_labelCurrentLocation;
    IBOutlet UIButton        *_buttonSubmit;
    IBOutlet UIActivityIndicatorView      *_activitySubmit;

    NSDate      *_previousSubmitDate;
    NSTimer     *_timer;

    BOOL        _isTimersetforMinutes;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentLocationChange:) name:kNewCurrentLocationNotificationFound object:nil];
    [LocationHelper startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    NSString *customerName = [[NSUserDefaults standardUserDefaults] stringForKey:kCustomerNameKey];
    if (nil != customerName && customerName.length) {
        _textfieldCustomerName.text = customerName;
    }else{
        _textfieldCustomerName.text = kDefaultCustomerName;
    }
    
    _previousSubmitDate = [StorageManager getLastSubmitDate];
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
    double latitude = [[LocationHelper sharedInstance] currentLocation].coordinate.latitude;
    double longitude = [[LocationHelper sharedInstance] currentLocation].coordinate.longitude;
    if (latitude == 0.0 && longitude == 0.0) {
        return;
    }

    [_textfieldCustomerName resignFirstResponder];
    [_buttonSubmit setUserInteractionEnabled:NO];
    [_activitySubmit startAnimating];
    NSString *userName = _textfieldCustomerName.text;
    NSDictionary *parameters = @{@"Name":userName,
                                 @"latitude":@(latitude),
                                 @"longitude":@(longitude)};
    [WebserviceOperation runWebservicewithParameters: parameters completionHander :^(WebServiceStatus status, NSString *submitDate, NSError* error){
        [_activitySubmit stopAnimating];
        [_buttonSubmit setUserInteractionEnabled:YES];
        if (nil == error) {
            _previousSubmitDate = [NSDate date];
            [StorageManager saveSubmitDate:_previousSubmitDate];
            _labelPreviousSubmitMessage.text = [self getDateMessage:0];
            [self startTimer:1.0];
        }else{
            NSLog(@"Error: %@", error.description);
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

-(void)currentLocationChange:(NSNotification *)notification{
    NSString *locationDescription = [LocationHelper sharedInstance].currentLocation.localizedCoordinateString;
    _labelCurrentLocation.text = locationDescription;
}

@end

LocationAssignment

================================================================================
ABSTRACT:

This demonstrate two major functionality: 1) Getting UserLocation and tracking
    the change in the user's location. 2) Using MKNetwork and calling the 
    webservice with the location data.

What to look for in this Project

• Use of CoreLocation framework for the user lcoation handling.

• MKNetwork Integration with callbacks when response received.

Location hadling code is used in ViewController class, which is also reponsible 
    for UI presented to user. For the network/webservice calls WebserviceOperation 
    class has been used.

This project also make use of “NSLocationWhenInUseUsageDescription” in its Info.plist 
    together with CLLocationManager’s requestWhenInUseAuthorization method.

================================================================================
BUILD REQUIREMENTS:

iOS 8.0 SDK or later

================================================================================
RUNTIME REQUIREMENTS:

iOS 7.0 or later

================================================================================

INSTALLATION INSTRUCTION:

Download the application from Git and run in the Xcode version 6.1 or later.

================================================================================

PACKAGING LIST:

AppDelegate:
There are couple of handy delegate method used, applicationDidEnterBackground 
    and applicationDidBecomeActive where application making the webservice call
    to notify to server the last (stored) location of user's location.

ViewController:
This is main viewController where UI is provided to enter the user's name and 
    current location is shown. Once user taps on SubmitButton webservice call 
    is made to post the preformated data i.e.:"data=Name is now at lat/long"

WebserviceOperation:
This class inherited from MKNetworkOperation and does the webservice/network 
    handling and notify the caller with the result.

StorageManager:
This class is handling the storage handling of user's entered name and handles 
    the last time submit date.

================================================================================
Contacts

If you want inform about bug fixes,
security fixes please raise the ticket in Git repository or shoot the mail uptscs@gmail.com

================================================================================
Copyright (C) 2014-2015 Upendra All rights reserved.
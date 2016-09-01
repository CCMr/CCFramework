//
//  UIApplication-Permissions.h
//  CCFramework
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>

@import CoreLocation;


@interface UIApplication (Permissions)

/**
 Returns `nil` in an application extension, otherwise returns the singleton app instance.

 @return `nil` in an application extension, otherwise the app instance is created in the `UIApplicationMain` function.
 */
+ (UIApplication *)cc_sharedApplication;

#pragma mark-
#pragma mark :. ApplicationSize

- (NSString *)applicationSize;

- (CGRect)keyboardFrame;

#pragma mark-
#pragma mark :. Permissions

typedef enum {
    kPermissionTypeBluetoothLE,
    kPermissionTypeCalendar,
    kPermissionTypeContacts,
    kPermissionTypeLocation,
    kPermissionTypeMicrophone,
    kPermissionTypeMotion,
    kPermissionTypePhotos,
    kPermissionTypeReminders,
} kPermissionType;

typedef enum {
    kPermissionAccessDenied,	   //User has rejected feature
    kPermissionAccessGranted,	  //User has accepted feature
    kPermissionAccessRestricted,       //Blocked by parental controls or system settings
    kPermissionAccessUnknown,	  //Cannot be determined
    kPermissionAccessUnsupported,      //Device doesn't support this - e.g Core Bluetooth
    kPermissionAccessMissingFramework, //Developer didn't import the required framework to the project
} kPermissionAccess;


//Check permission of service. Cannot check microphone or motion without asking user for permission
- (kPermissionAccess)hasAccessToBluetoothLE;
- (kPermissionAccess)hasAccessToCalendar;
- (kPermissionAccess)hasAccessToContacts;
- (kPermissionAccess)hasAccessToLocation;
- (kPermissionAccess)hasAccessToPhotos;
- (kPermissionAccess)hasAccessToReminders;

//Request permission with callback
- (void)requestAccessToCalendarWithSuccess:(void (^)())accessGranted andFailure:(void (^)())accessDenied;
- (void)requestAccessToContactsWithSuccess:(void (^)())accessGranted andFailure:(void (^)())accessDenied;
- (void)requestAccessToMicrophoneWithSuccess:(void (^)())accessGranted andFailure:(void (^)())accessDenied;
- (void)requestAccessToPhotosWithSuccess:(void (^)())accessGranted andFailure:(void (^)())accessDenied;
- (void)requestAccessToRemindersWithSuccess:(void (^)())accessGranted andFailure:(void (^)())accessDenied;

//Instance methods
- (void)requestAccessToLocationWithSuccess:(void (^)())accessGranted andFailure:(void (^)())accessDenied;

//No failure callback available
- (void)requestAccessToMotionWithSuccess:(void (^)())accessGranted;

//Needs investigating - unsure whether it can be implemented because of required delegate callbacks
//-(void)requestAccessToBluetoothLEWithSuccess:(void(^)())accessGranted;



@end

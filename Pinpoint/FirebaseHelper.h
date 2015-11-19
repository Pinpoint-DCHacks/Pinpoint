//
//  FirebaseHelper.h
//  Pinpoint
//
//  Created by Spencer Atkin on 11/18/15.
//  Copyright © 2015 Pinpoint-DCHacks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Firebase/Firebase.h>
#import <UAObfuscatedString/UAObfuscatedString.h>

#define kPinpointURL [FirebaseHelper firebaseURL]

@interface FirebaseHelper : NSObject

+ (void)updateReadRules:(NSArray *)canView;
+ (void)updateLocation:(CLLocation *)location;
+ (NSString *)firebaseURL;

@end

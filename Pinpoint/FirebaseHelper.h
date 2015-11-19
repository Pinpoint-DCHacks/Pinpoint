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

#define kPinpointURL @"pinpoint.firebaseio.com"

@interface FirebaseHelper : NSObject

+ (void)updateReadRules:(NSArray *)canView;
+ (void)updateLocation:(CLLocation *)location;

@end

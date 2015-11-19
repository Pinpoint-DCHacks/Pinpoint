//
//  LocationDelegate.h
//  Pinpoint
//
//  Created by Spencer Atkin on 11/19/15.
//  Copyright © 2015 Pinpoint-DCHacks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationDelegate : NSObject <CLLocationManagerDelegate>

+ (instancetype)sharedInstance;

- (void)updateOnce;

- (void)beginUpdates;

- (void)endUpdates;

- (BOOL)isRunning;

@end

//
//  LocationDelegate.m
//  Pinpoint
//
//  Created by Spencer Atkin on 11/19/15.
//  Copyright © 2015 Pinpoint-DCHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationDelegate.h"
#import "UserData.h"
#import "FirebaseHelper.h"

@interface LocationDelegate ()
@property (strong, nonatomic) CLLocationManager *manager;
@property (nonatomic) UIBackgroundTaskIdentifier task;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation LocationDelegate

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    static LocationDelegate *_sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (BOOL)isRunning {
    return [self.timer isValid];
}

- (void)initializeManager {
    self.manager = [[CLLocationManager alloc] init];
    self.manager.delegate = self;
    [self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
}

- (void)updateOnce {
    [self initializeManager];
    [self.manager requestLocation];
}

UIBackgroundTaskIdentifier locationBackgroundTask;
- (void)beginUpdates {
    NSLog(@"begun");
    [self initializeManager];
    locationBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:locationBackgroundTask];
        locationBackgroundTask = UIBackgroundTaskInvalid;
    } ];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerSent:) userInfo:nil repeats:YES];
    //[self timerSent];
}

- (void)timerSent:(NSTimer *)timer {
    NSLog(@"timer called");
    [self.manager requestLocation];
}

- (void)endUpdates {
    NSLog(@"Ending updates");
    [[UIApplication sharedApplication] endBackgroundTask:locationBackgroundTask];
    [self.timer invalidate];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.task = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"Location-send" expirationHandler:^{
        NSLog(@"Expired");
        self.task = UIBackgroundTaskInvalid;
    }];
    NSLog(@"uid: %@", [UserData sharedInstance].uid);
    NSLog(@"username: %@", [UserData sharedInstance].username);
    if ([locations lastObject] != nil) {
        NSLog(@"Location update");
        if ([UserData sharedInstance].uid != nil) {
            [FirebaseHelper updateLocation:[locations lastObject]];
        }
        //[self.manager stopUpdatingLocation];
        /*if (!updateOnce) {
            [self.manager performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:5];
        }*/
    }
    [[UIApplication sharedApplication] endBackgroundTask:self.task];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed with error: %@", error);
}

@end

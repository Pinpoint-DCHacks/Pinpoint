//
//  FirebaseHelper.m
//  Pinpoint
//
//  Created by Spencer Atkin on 11/18/15.
//  Copyright © 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "FirebaseHelper.h"
#import <GeoFire/GeoFire.h>
#import "UserData.h"

@interface FirebaseHelper ()
@end

@implementation FirebaseHelper

+ (void)updateLocation:(CLLocation *)location {
    Firebase *ref = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/locations/%@", kPinpointURL, [UserData sharedInstance].uid]];
    GeoFire *geofire = [[GeoFire alloc] initWithFirebaseRef:ref];
    [ref authUser:[UserData sharedInstance].email password:[UserData sharedInstance].password withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            NSLog(@"Error logging in");
        }
        else {
            [geofire setLocation:location forKey:@"location" withCompletionBlock:^(NSError *error) {
                if (error == nil) {
                    NSLog(@"Wrote new location to %@", [UserData sharedInstance].uid);
                }
                else {
                    NSLog(@"Error posting location %@", error);
                }
            }];
        }
    }];
}

+ (void)updateReadRules:(NSArray *)canView {
    Firebase *ref = [[Firebase alloc] initWithUrl: [NSString stringWithFormat:@"%@/locations", kPinpointURL]];
    NSMutableDictionary *users = [[NSMutableDictionary alloc] initWithCapacity:[canView count]];
    for (NSInteger x = 0; x < [canView count]; x++) {
        users[canView[x]] = @"true";
    }
    NSLog(@"users: %@", users);
    [ref authUser:[UserData sharedInstance].email password:[UserData sharedInstance].password withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            NSLog(@"Error logging in: %@", error);
            if (error.code == -15) {
                // Internet connection appears to be offline
            }
        }
        else {
            NSLog(@"Logged in %@ successfully", [UserData sharedInstance].email);
            [[ref childByAppendingPath:[NSString stringWithFormat:@"%@/authUsers", [UserData sharedInstance].uid]] setValue:users withCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error) {
                    NSLog(@"Error updating read rules");
                }
                else {
                    NSLog(@"Successfully updated read rules");
                }
            }];;
        }
    }];
}

+ (NSString *)firebaseURL {
    static dispatch_once_t p = 0;
    static NSString *url = nil;
    
    dispatch_once(&p, ^{
        url = Obfuscate.p.i.n.p.o.i.n.t.dot.f.i.r.e.b.a.s.e.i.o.dot.c.o.m;
    });
    return url;
}

@end

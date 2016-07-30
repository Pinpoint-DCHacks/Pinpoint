//
//  FirebaseHelper.m
//  Pinpoint
//
//  Created by Spencer Atkin on 11/18/15.
//  Copyright © 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "FirebaseHelper.h"
#import "GeoFire.h"
#import "UserData.h"
#import <FirebaseAuth/FirebaseAuth.h>

@interface FirebaseHelper ()
@end

@implementation FirebaseHelper

+ (void)updateLocation:(CLLocation *)location {
    FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:[NSString stringWithFormat:@"locations/%@", [UserData sharedInstance].uid]];
    GeoFire *geofire = [[GeoFire alloc] initWithFirebaseRef:ref];
    [FirebaseHelper authWithEmail:[UserData sharedInstance].email password:[UserData sharedInstance].password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
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
    FIRDatabaseReference *ref = [[[FIRDatabase database] reference] child:@"locations"];
    NSMutableDictionary *users = [[NSMutableDictionary alloc] initWithCapacity:[canView count]];
    for (NSInteger x = 0; x < [canView count]; x++) {
        users[canView[x]] = @"true";
    }
    NSLog(@"users: %@", users);
    [FirebaseHelper authWithEmail:[UserData sharedInstance].email password:[UserData sharedInstance].password completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error logging in: %@", error);
            if (error.code == -15) {
                // Internet connection appears to be offline
            }
        }
        else {
            NSLog(@"Logged in %@ successfully", [UserData sharedInstance].email);
            [[ref child:[NSString stringWithFormat:@"%@/authUsers", [UserData sharedInstance].uid]] setValue:users withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref) {
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

+ (void)authWithEmail:(NSString *)email password:(NSString *)password completion:(FirebaseHelperCompletion)completion {
    FIRAuthStateDidChangeListenerHandle handle = [[FIRAuth auth] addAuthStateDidChangeListener:^(FIRAuth * _Nonnull auth, FIRUser * _Nullable user) {
        if (user) {
            NSLog(@"Already logged in with uid: %@", user.uid);
            completion(user, nil);
        } else {
            NSLog(@"Logging in");
            [[FIRAuth auth] signInWithEmail:email password:password completion:completion];
        }
    }];
    [[FIRAuth auth] removeAuthStateDidChangeListener:handle];
}

/*
+ (NSString *)firebaseURL {
    static dispatch_once_t p = 0;
    static NSString *url = nil;
    
    dispatch_once(&p, ^{
        url = Obfuscate.p.i.n.p.o.i.n.t.dot.f.i.r.e.b.a.s.e.i.o.dot.c.o.m;
    });
    return url;
}
*/

@end

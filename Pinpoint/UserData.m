//
//  UserData.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/6/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "UserData.h"

@implementation UserData

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    static UserData *_sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)load {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    self.auth = [def objectForKey:@"firebase.auth"];
    self.name = [def objectForKey:@"name"];
    self.number = [def objectForKey:@"number"];
    self.email = [def objectForKey:@"email"];
    self.uid = [def objectForKey:@"firebase.uid"];
    self.uid = [def objectForKey:@"password"];
    [def synchronize];
}

- (void)save {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:self.auth forKey:@"firebase.auth"];
    [def setObject:self.name forKey:@"name"];
    [def setObject:self.number forKey:@"number"];
    [def setObject:self.email forKey:@"email"];
    [def setObject:self.uid forKey:@"firebase.uid"];
    [def setObject:self.password forKey:@"password"];
    [def synchronize];
}

@end

//
//  FireUser.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/6/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "FireUser.h"

@implementation FireUser

- (instancetype)initWithIdentifier:(NSString *)uid username:(NSString *)username {
    self = [super init];
    if (self) {
        self.uid = uid;
        self.username = username;
    }
    return self;
}

@end

//
//  FireUser.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/6/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "FireUser.h"

@implementation FireUser

- (instancetype)initWithName:(NSString *)name identifier:(NSString *)uid {
    self = [super init];
    if (self) {
        self.name = name;
        self.uid = uid;
    }
    return self;
}

@end

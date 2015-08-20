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

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.uid forKey:@"self.uid"];
    [aCoder encodeObject:self.username forKey:@"self.username"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.uid = [aDecoder decodeObjectForKey:@"self.uid"];
        self.username = [aDecoder decodeObjectForKey:@"self.username"];
    }
    return self;
}

@end

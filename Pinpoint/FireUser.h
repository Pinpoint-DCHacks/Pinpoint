//
//  FireUser.h
//  Pinpoint
//
//  Created by Spencer Atkin on 8/6/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FireUser : NSObject
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *uid;

- (instancetype)initWithIdentifier:(NSString *)uid username:(NSString *)username;
@end

//
//  UserData.h
//  Pinpoint
//
//  Created by Spencer Atkin on 8/6/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>

@interface UserData : NSObject

@property (strong, nonatomic) FAuthData *auth;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *uid;

+ (instancetype)sharedInstance;

- (void)load;
- (void)save;

@end

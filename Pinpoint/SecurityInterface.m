//
//  SecurityInterface.m
//  Pinpoint
//
//  Created by Spencer Atkin on 11/13/15.
//  Copyright © 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "SecurityInterface.h"
#import <Firebase/Firebase.h>
#import "UserData.h"

#define kPinpointURL @"pinpoint.firebaseio.com"

@implementation SecurityInterface

+ (void)updateReadRules:(NSArray *)canView {
    Firebase *ref = [[Firebase alloc] initWithUrl: @"pinpoint.firebaseio.com/locations"];
    
    NSMutableDictionary *users = [[NSMutableDictionary alloc] initWithCapacity:[canView count]];
    for (NSInteger x = 0; x < [canView count]; x++) {
        users[canView[x]] = @"true";
    }
    
    [[ref childByAppendingPath:[NSString stringWithFormat:@"%@/authUsers", [UserData sharedInstance].uid]] setValue:users withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (error) {
            NSLog(@"Error updating read rules");
        }
        else {
            NSLog(@"Successfully updated read rules");
        }
    }];;
}
@end

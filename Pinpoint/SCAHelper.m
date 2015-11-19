//
//  SCAHelper.m
//  Pinpoint
//
//  Created by Spencer Atkin on 11/18/15.
//  Copyright © 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "SCAHelper.h"

@implementation SCAHelper

void sca_dispatch_sync_on_main_thread(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end

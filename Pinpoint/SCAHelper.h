//
//  SCAHelper.h
//  Pinpoint
//
//  Created by Spencer Atkin on 11/18/15.
//  Copyright © 2015 Pinpoint-DCHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCAHelper : NSObject

extern void sca_dispatch_sync_on_main_thread(dispatch_block_t block);

@end

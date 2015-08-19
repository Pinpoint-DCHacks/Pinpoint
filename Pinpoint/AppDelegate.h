//
//  AppDelegate.h
//  Pinpoint
//
//  Created by Spencer Atkin on 8/1/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuController.h"

#define kSideMenuController ((SideMenuController *)[[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end


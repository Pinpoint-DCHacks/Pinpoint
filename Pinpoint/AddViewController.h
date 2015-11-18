//
//  AddViewController.h
//  Pinpoint
//
//  Created by Spencer Atkin on 8/8/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddViewController : UIViewController <UITextFieldDelegate>
extern NSString *const ContactsChangedNotification;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) NSMutableArray *contacts;

+ (void)registerObserver:(void (^)(NSNotification *))block;
@end

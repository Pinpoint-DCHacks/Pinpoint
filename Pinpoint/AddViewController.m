//
//  AddViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/8/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "AddViewController.h"
#import "UserData.h"
#import "FireUser.h"
#import "KSToastView.h"
#import "RSTToastView.h"
#import "SCAHelper.h"
#import "FirebaseHelper.h"
#import <UITextField+Shake/UITextField+Shake.h>

@interface AddViewController ()
@property (strong, nonatomic) RSTToastView *toastView;
@end

NSString *const ContactsChangedNotification = @"ContactsChangedNotification";

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameTextField.delegate = self;
    [self.usernameTextField becomeFirstResponder];
    self.toastView = [[RSTToastView alloc] initWithMessage:@""];
    self.toastView.tintColor = [UIColor colorWithRed:(43.0/255.0) green:(65.0/255.0) blue:(98.0/255.0) alpha:1.0f];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)registerObserver:(void (^)(NSNotification *))block {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:ContactsChangedNotification
                        object:nil
                         queue:nil
                    usingBlock:block];
}

+ (void)notifyChange:(NSArray *)contacts {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:ContactsChangedNotification object:contacts];
}

- (IBAction)didTapAdd:(id)sender {
    if ([self.usernameTextField.text isEqualToString:@""]) {
        [self.usernameTextField shake:10 withDelta:5];
    }
    else {
        NSLog(@"Not empty");
        Firebase *ref = [[Firebase alloc] initWithUrl:kPinpointURL];
        [ref authUser:[UserData sharedInstance].email password:[UserData sharedInstance].password withCompletionBlock:^(NSError *error, FAuthData *authData) {
            [[ref childByAppendingPath:[NSString stringWithFormat:@"usernames/%@", self.usernameTextField.text]] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                NSLog(@"Observing FEventTypeValue");
                if ([snapshot.value isKindOfClass:[NSNull class]]) {
                    NSLog(@"Does not exist");
                    sca_dispatch_sync_on_main_thread(^{
                        if (!self.toastView.isVisible) {
                            self.toastView.message = @"That user doesn't exist";
                            [self.toastView showForDuration:1.0f];
                        }
                    });
                    //[KSToastView ks_showToast:@"That user does not exist." duration:1.0f];
                    sca_dispatch_sync_on_main_thread(^{
                        [self.usernameTextField shake:10 withDelta:5];
                    });
                }
                else {
                    NSLog(@"Contact valid");
                    BOOL exists = NO;
                    // Checks is user with this username has already been added.
                    for (NSInteger x = 0; x < [self.contacts count]; x++) {
                        if ([((FireUser *)[self.contacts objectAtIndex:x]).username isEqualToString:self.usernameTextField.text]) {
                            exists = YES;
                            break;
                        }
                    }
                    if (!exists) {
                        [self.contacts addObject:[[FireUser alloc] initWithIdentifier:snapshot.value username:self.usernameTextField.text]];
                        [AddViewController notifyChange:self.contacts];
                        [self.usernameTextField resignFirstResponder];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    else {
                        [self.usernameTextField shake:10 withDelta:5];
                    }
                }
                //[self performSelector:@selector(cancel) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
            }];
        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self didTapAdd:textField];
    return NO;
}

- (IBAction)didTapCancel:(id)sender {
    [self.usernameTextField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

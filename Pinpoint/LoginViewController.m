//
//  LoginViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/6/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "LoginViewController.h"
#import "CreateAccountViewController.h"
#import "UserData.h"
#import <Firebase/Firebase.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapLogin:(id)sender {
    NSLog(@"Logging in %@", self.emailText.text);
    [[UserData sharedRef] authUser:self.emailText.text password:self.passwordText.text withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            NSLog(@"Error logging in: %@", error);
            NSString *title = @"Error logging in";
            NSString *message = @"Please try again.";
            if (error.code == -5) {
                title = @"Invalid email";
            }
            else if (error.code == -8) {
                title = @"Invalid email";
            }
            else if (error.code == -6) {
                title = @"Incorrect password";
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            __block UserData *dat = [UserData sharedInstance];
            dat.uid = authData.uid;
            NSLog(@"UID: %@", authData.uid);
            [[[UserData sharedRef] childByAppendingPath:[NSString stringWithFormat:@"uids/%@", dat.uid]] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if (error) {
                    NSLog(@"Error getting username: %@", error);
                }
                else {
                    NSLog(@"user being logged in: %@", snapshot.value);
                    dat.username = snapshot.value;
                    NSLog(@"Successfully logged in.");
                    dat.email = self.emailText.text;
                    dat.password = self.passwordText.text;
                    [dat save];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        }
    }];
}

- (IBAction)didTapCreate:(id)sender {
    [self performSegueWithIdentifier:@"ShowCreateSegue" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowCreateSegue"]) {
        ((CreateAccountViewController *)segue.destinationViewController).emailText.text = self.emailText.text;
        ((CreateAccountViewController *)segue.destinationViewController).passText.text = self.passwordText.text;
        [((CreateAccountViewController *)segue.destinationViewController).usernameText becomeFirstResponder];
    }
}


@end

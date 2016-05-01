//
//  CreateAccountViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/1/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "UserData.h"
#import "RMPhoneFormat.h"
#import "FirebaseHelper.h"
#import <Firebase/Firebase.h>

//#define kPinpointURL @"pinpoint.firebaseio.com"

@interface CreateAccountViewController ()

@end

@implementation CreateAccountViewController {
    RMPhoneFormat *phoneFormat;
    NSMutableCharacterSet *phoneChars;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.numberText.delegate = self;
    phoneFormat = [[RMPhoneFormat alloc] init];
    phoneChars = [[NSCharacterSet decimalDigitCharacterSet] mutableCopy];
    [phoneChars addCharactersInString:@"+*#,"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapRegister:(id)sender {
    __block UserData *data = [UserData sharedInstance];
    
    Firebase *ref = [[Firebase alloc] initWithUrl:kPinpointURL];
    // Checks if username is used
    FirebaseHandle handle = [[ref childByAppendingPath:[NSString stringWithFormat:@"usernames/%@", data.username]] observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        // No user exists with this username
        if ([snapshot.value isKindOfClass:[NSNull class]]) {
            // Create user based on credentials
            [ref createUser:self.emailText.text password:self.passText.text withValueCompletionBlock:^(NSError *error, NSDictionary *result) {
                if (error) {
                    NSLog(@"Error creating user: %@", error);
                }
                else {
                    [ref authUser:self.emailText.text password:self.passText.text withCompletionBlock:^(NSError *error, FAuthData *authData) {
                        if (error) {
                            NSLog(@"Error logging in %@", error);
                        }
                        else {
                            NSLog(@"Sucessfully logged in");
                            data.uid = authData.uid;
                            [data save];
                            [[ref childByAppendingPath:@"uids"] updateChildValues:@{authData.uid: self.usernameText.text} withCompletionBlock:^(NSError *error, Firebase *ref) {
                                if (error) {
                                    NSLog(@"Error writing uid %@", error);
                                }
                                else {
                                    NSLog(@"Wrote uid successfully");
                                    NSLog(@"Username: %@", data.username);
                                }
                            }];
                            [[ref childByAppendingPath:@"usernames"] updateChildValues:@{self.usernameText.text: authData.uid} withCompletionBlock:^(NSError *error, Firebase *ref) {
                                if (error) {
                                    NSLog(@"Error writing username: %@", error);
                                }
                                else {
                                    NSLog(@"Wrote username successfully");
                                }
                            }];
                            data.name = self.nameText.text;
                            data.username = self.usernameText.text;
                            data.number = self.numberText.text;
                            data.email = self.emailText.text;
                            data.password = self.passText.text;
                            [data save];
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                }
            }];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Username is taken" message:@"Please try another." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } withCancelBlock:^(NSError *error) {
        NSLog(@"Error observing: %@", error.description);
    }];
    [ref removeObserverWithHandle:handle];
}

/*- (NSString *)formatPhoneNumber:(NSString *)number {
    NSMutableArray *numberArray = [[NSMutableArray alloc] initWithArray:[number componentsSeparatedByString:@""]];
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSInteger x = 0; x < [numberArray count]; x++) {
        if ([numberArray[x] integerValue] == 0) {
            if (![numberArray[x] isEqualToString:@"0"]) {
                [numberArray removeObjectAtIndex:x];
                x--;
            }
            else {
                [returnArray addObject:numberArray[x]];
            }
        }
        else {
            [returnArray addObject:numberArray[x]];
        }
    }
    return [returnArray componentsJoinedByString:@""];
}*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    UITextRange *selRange = textField.selectedTextRange;
    UITextPosition *selStartPos = selRange.start;
    UITextPosition *selEndPos = selRange.end;
    NSInteger start = [textField offsetFromPosition:textField.beginningOfDocument toPosition:selStartPos];
    NSInteger end = [textField offsetFromPosition:textField.beginningOfDocument toPosition:selEndPos];
    NSRange repRange;
    if (start == end) {
        if (string.length == 0) {
            repRange = NSMakeRange(start - 1, 1);
        } else {
            repRange = NSMakeRange(start, end - start);
        }
    } else {
        repRange = NSMakeRange(start, end - start);
    }
    
    // This is what the new text will be after adding/deleting 'string'
    NSString *txt = [textField.text stringByReplacingCharactersInRange:repRange withString:string];
    // This is the newly formatted version of the phone number
    NSString *phone = [phoneFormat format:txt];
    BOOL valid = [phoneFormat isPhoneNumberValid:phone];
    
    textField.textColor = valid ? [UIColor blackColor] : [UIColor redColor];
    
    // If these are the same then just let the normal text changing take place
    if ([phone isEqualToString:txt]) {
        return YES;
    } else {
        // The two are different which means the adding/removal of a character had a bigger effect
        // from adding/removing phone number formatting based on the new number of characters in the text field
        // The trick now is to ensure the cursor stays after the same character despite the change in formatting.
        // So first let's count the number of non-formatting characters up to the cursor in the unchanged text.
        int cnt = 0;
        for (NSUInteger i = 0; i < repRange.location + string.length; i++) {
            if ([phoneChars characterIsMember:[txt characterAtIndex:i]]) {
                cnt++;
            }
        }
        
        // Now let's find the position, in the newly formatted string, of the same number of non-formatting characters.
        NSUInteger pos = [phone length];
        NSUInteger cnt2 = 0;
        for (NSUInteger i = 0; i < [phone length]; i++) {
            if ([phoneChars characterIsMember:[phone characterAtIndex:i]]) {
                cnt2++;
            }
            
            if (cnt2 == cnt) {
                pos = i + 1;
                break;
            }
        }
        
        // Replace the text with the updated formatting
        textField.text = phone;
        
        // Make sure the caret is in the right place
        UITextPosition *startPos = [textField positionFromPosition:textField.beginningOfDocument offset:pos];
        UITextRange *textRange = [textField textRangeFromPosition:startPos toPosition:startPos];
        textField.selectedTextRange = textRange;
        
        return NO;
    }
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

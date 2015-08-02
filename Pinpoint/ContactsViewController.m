//
//  ContactsViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/1/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "ContactsViewController.h"
#import "MapViewController.h"
@import AddressBook;

@interface ContactsViewController ()

@end

@implementation ContactsViewController

NSString *cellID = @"TableCellID";
NSMutableArray *contacts;
NSMutableArray *names;
NSMutableArray *phoneNumbers;
NSIndexPath *selected;
/*NSArray *searchResults;
NSMutableArray *numbers;
NSArray *numberSearchResults;*/

- (void)viewDidLoad {
    [super viewDidLoad];
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self importContacts];
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    [super loadView];
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self.importButton removeFromSuperview];
    }
    else {
        [self.tableView setHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [self performSegueWithIdentifier:@"ShowStartSegue" sender:self];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)importContacts {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    contacts = (__bridge NSMutableArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    names = [[NSMutableArray alloc] initWithCapacity:[contacts count]];
    phoneNumbers = [[NSMutableArray alloc] init];
    for (NSInteger x = 0; x < [contacts count]; x++) {
        NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)contacts[x], kABPersonFirstNameProperty);
        NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)contacts[x], kABPersonLastNameProperty);
        ABMultiValueRef mobilePhone = ABRecordCopyValue((__bridge ABRecordRef)contacts[x], kABPersonPhoneProperty);
        NSString *phoneString = (__bridge NSString*)ABMultiValueCopyValueAtIndex(mobilePhone, 0);
        CFRelease(mobilePhone);
        if (firstName == nil || lastName == nil || phoneString == nil) {
            [contacts removeObjectAtIndex:x];
            x -= 1;
        }
        else {
            NSString *formattedString = [self formatPhoneNumber:phoneString];
            
            if (!(formattedString == nil || [formattedString length] == 0)) {
                NSString *nameString = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                [names addObject:nameString];
                [phoneNumbers addObject:formattedString];
            }
            else {
                [contacts removeObjectAtIndex:x];
                x -= 1;
            }
            NSLog(@"phoneArray: %@ %@", phoneString, [phoneString class]);
            NSLog(@"phone numbers: %@", phoneNumbers);
            //NSLog(@"%@", (__bridge_transfer NSString*)ABRecordCopyValue((__bridge ABRecordRef)contacts[x], kABPersonPhoneProperty));
        }
    }
    //NSLog(@"%@", contacts);
    
}

- (NSString *)formatPhoneNumber:(NSString *)number {
    NSMutableArray *numberArray = [[NSMutableArray alloc] init];//[[NSMutableArray alloc] initWithArray:[number componentsSeparatedByString:@""]];
    for (NSInteger x = 0; x < [number length]; x++) {
        [numberArray addObject:[NSString stringWithFormat:@"%C", [number characterAtIndex:x]]];
    }
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSInteger x = 0; x < [numberArray count]; x++) {
        /*if ([numberArray[x] integerValue] == 0) {
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
        }*/
        NSLog(@"%ld %@", x, numberArray[x]);
        if ([numberArray[x] isEqualToString:@"("] || [numberArray[x] isEqualToString:@")"] || [numberArray[x] isEqualToString:@"-"] || [numberArray[x] isEqualToString:@" "]) {
            [numberArray removeObjectAtIndex:x];
            x--;
        }
        else {
            [returnArray addObject:numberArray[x]];
        }
    }
    return [returnArray componentsJoinedByString:@""];
}

- (IBAction)didTapImport:(id)sender {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted) {
        NSLog(@"Denied");
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [sender removeFromSuperview];
        NSLog(@"Authorized");
    }
    else { //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        NSLog(@"Hello");
        UIAlertController *requestContacts = [UIAlertController alertControllerWithTitle:@"Import Contacts?" message:@"You'll have to give contacts access." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
                if (!granted){
                    NSLog(@"Just denied");
                    return;
                }
                NSLog(@"Just authorized");
                [sender removeFromSuperview];
                [self.tableView setHidden:NO];
                [self importContacts];
            });
        }];
        [requestContacts addAction:cancel];
        [requestContacts addAction:confirm];
        [self presentViewController:requestContacts animated:YES completion:nil];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //if (tableView == self.searchDisplayController.searchResultsTableView) {
    //    return [searchResults count];
    //}
    //else {
        return [contacts count];
    //}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSString *name = nil;
    //if (tableView == self.searchDisplayController.searchResultsTableView) {
    //    name = [searchResults objectAtIndex:indexPath.row];
    //
    //} else {
        name = [names objectAtIndex:indexPath.row];
    //}
    [cell.textLabel setText:name];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selected = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ShowMapSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

/*- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchText];
    searchResults = [names filteredArrayUsingPredicate:resultPredicate];
}*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowMapSegue"]) {
        [((MapViewController *)[segue destinationViewController]) setRecipientNumber:phoneNumbers[selected.row]];
        [[[segue destinationViewController] navigationItem] setTitle:[[sender textLabel] text]];
    }
}


@end

//
//  ContactsViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/1/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "ContactsViewController.h"
#import "UserData.h"
#import "MapViewController.h"
#import <GeoFire/GeoFire+Private.h>
@import AddressBook;

#define kPinpointURL @"pinpoint.firebaseio.com"

@interface ContactsViewController ()
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) GeoFire *geofire;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sharingButton;
@property (nonatomic) UIBackgroundTaskIdentifier task;
@end

@implementation ContactsViewController

NSString *cellID = @"TableCellID";
NSMutableArray *contacts;
NSMutableArray *names;
NSMutableArray *phoneNumbers;
NSIndexPath *selected;
BOOL accessAllowed = false;
BOOL updateOnce = false;
NSString *pin = @"12345";

- (void)viewDidLoad {
    [super viewDidLoad];
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self importContacts];
    }
    NSLog(@"Number: %@", [UserData sharedInstance].number);
    NSLog(@"Email: %@", [UserData sharedInstance].email);
    self.firebase = [[Firebase alloc] initWithUrl:kPinpointURL];
    self.geofire = [[GeoFire alloc] initWithFirebaseRef:self.firebase];
    [self.firebase authUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"email"] password:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] withCompletionBlock:^(NSError *error, FAuthData *authData) {
        if (error) {
            NSLog(@"Error logging in: %@", error);
        }
        else {
            NSLog(@"Successfully logged in");
            [UserData sharedInstance].uid = authData.uid;
        }
    }];
    // Do any additional setup after loading the view.
}

- (IBAction)didTapShare:(id)sender {
    updateOnce = false;
    if ([self.sharingButton.title isEqualToString:@"Start Sharing"]) {
        self.sharingButton.title = @"Stop Sharing";
        self.manager = [[CLLocationManager alloc] init];
        [self.manager setDelegate:self];
        [self checkAlwaysAuthorization];
        [self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.manager startUpdatingLocation];
    }
    else {
        self.sharingButton.title = @"Start Sharing";
        [self.manager stopUpdatingLocation];
        [NSObject cancelPreviousPerformRequestsWithTarget:self.manager];
    }
}

- (IBAction)didTapShareOnce:(id)sender {
    updateOnce = true;
    self.manager = [[CLLocationManager alloc] init];
    [self.manager setDelegate:self];
    [self checkAlwaysAuthorization];
    [self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.task = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"Location-send" expirationHandler:^{
        NSLog(@"Expired");
        self.task = UIBackgroundTaskInvalid;
    }];
    if ([locations lastObject] != nil) {
        NSLog(@"Location update");
        NSLog(@"%@", [UserData sharedInstance].number);
        if ([UserData sharedInstance].number != nil) {
            [[self.firebase childByAppendingPath:[NSString stringWithFormat:@"%@/userData", [UserData sharedInstance].uid]] updateChildValues:@{@"test":@"test"} withCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error == nil) {
                    NSLog(@"Wrote to location");
                }
            }];
            [self.geofire setLocation:[locations lastObject] forKey:[UserData sharedInstance].uid withCompletionBlock:^(NSError *error) {
                if (error == nil) {
                    NSLog(@"Wrote new location to %@", [UserData sharedInstance].number);
                }
                else {
                    NSLog(@"Error posting location %@", error);
                }
            }];
        }
        [self.manager stopUpdatingLocation];
        if (!updateOnce) {
            [self.manager performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:5];
        }
    }
    [[UIApplication sharedApplication] endBackgroundTask:self.task];
}

- (void)checkAlwaysAuthorization {
    NSLog(@"Checking status");
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSLog(@"Denied");
        NSString *title =  (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:settingsAction];
        [self showViewController:alertController sender:self];
    }
    
    else if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"requesting");
        if([self.manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.manager requestAlwaysAuthorization];
        }
    }
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
    UIAlertController *pinShower = [UIAlertController alertControllerWithTitle:@"PIN" message:[NSString stringWithFormat:@"Pin for Kate Bell is %@", pin] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [pinShower addAction:ok];
    [self presentViewController:pinShower animated:YES completion:nil];
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
        if (!([numberArray[x] isEqualToString:@"1"] || [numberArray[x] isEqualToString:@"2"] || [numberArray[x] isEqualToString:@"3"] || [numberArray[x] isEqualToString:@"4"] || [numberArray[x] isEqualToString:@"5"] || [numberArray[x] isEqualToString:@"6"] || [numberArray[x] isEqualToString:@"7"] || [numberArray[x] isEqualToString:@"8"] || [numberArray[x] isEqualToString:@"9"] || [numberArray[x] isEqualToString:@"0"])) {
            if ([numberArray[x] isEqualToString:@"+"]) {
                [numberArray removeObjectAtIndex:x];
                [numberArray removeObjectAtIndex:x+1];
                x -= 2;
            }
            else {
                [numberArray removeObjectAtIndex:x];
                x--;
            }
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
        return [contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSString *name = nil;
    name = [names objectAtIndex:indexPath.row];
    [cell.textLabel setText:name];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selected = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIAlertController *pinInput = [UIAlertController alertControllerWithTitle:@"Input pin" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [pinInput addTextFieldWithConfigurationHandler:nil];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *pinField = pinInput.textFields.firstObject;
        if ([pinField.text isEqualToString:pin]) {
            [self performSegueWithIdentifier:@"ShowMapSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
    }];
    [pinInput addAction:cancel];
    [pinInput addAction:ok];
    [self presentViewController:pinInput animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowMapSegue"]) {
        [((MapViewController *)[segue destinationViewController]) setRecipientNumber:phoneNumbers[selected.row]];
        [[[segue destinationViewController] navigationItem] setTitle:[[sender textLabel] text]];
    }
}


@end

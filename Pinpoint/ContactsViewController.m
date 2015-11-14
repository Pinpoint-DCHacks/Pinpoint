//
//  ContactsViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/1/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "ContactsViewController.h"
#import "UserData.h"
#import "AppDelegate.h"
#import "MapViewController.h"
#import "LoginViewController.h"
#import "AddViewController.h"
#import "SideMenuController.h"
#import "FireUser.h"
#import <GeoFire/GeoFire+Private.h>
#import <SDCAlertController.h>
#import <UITextField+Shake/UITextField+Shake.h>
#import "KSToastView.h"
#import "SecurityInterface.h"
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
//NSMutableArray *contacts;
//NSMutableArray *names;
//NSMutableArray *phoneNumbers;
BOOL accessAllowed = false;
BOOL updateOnce = false;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSData *contactsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"contacts"];
    if (contactsData) {
        self.contacts = [NSKeyedUnarchiver unarchiveObjectWithData:contactsData];
    }
    if (!self.contacts) {
        self.contacts = [[NSMutableArray alloc] init];
    }
    /*if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self importContacts];
    }*/
    self.firebase = self.firebase = [[Firebase alloc] initWithUrl: @"pinpoint.firebaseio.com/locations"];
    self.geofire = [[GeoFire alloc] initWithFirebaseRef:self.firebase];
    
    // Initialize location manager
    self.manager = [[CLLocationManager alloc] init];
    [self.manager setDelegate:self];
    
    // Register observer for contacts being added
    [AddViewController registerObserver:^(NSNotification *note) {
        if (note.name != ContactsChangedNotification) {
            return;
        }
        NSLog(@"Observed contacts change");
        self.contacts = note.object;
        [self.tableView reloadData];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.contacts] forKey:@"contacts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    // Do any additional setup after loading the view.
}

- (void)awakeFromNib {
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:@selector(openLeftView)];
}

- (IBAction)openLeftView:(id)sender {
    [kSideMenuController showLeftViewAnimated:YES completionHandler:nil];
}

- (IBAction)didTapShare:(id)sender {
    updateOnce = false;
    if ([self.sharingButton.title isEqualToString:@"Start Sharing"]) {
        [KSToastView ks_showToast:@"Started sharing location." duration:1.0f];
        self.sharingButton.title = @"Stop Sharing";
        [self checkAlwaysAuthorization];
        [self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.manager startUpdatingLocation];
    }
    else {
        [KSToastView ks_showToast:@"Stopped sharing location." duration:1.0f];
        self.sharingButton.title = @"Start Sharing";
        [self.manager stopUpdatingLocation];
        [NSObject cancelPreviousPerformRequestsWithTarget:self.manager];
    }
}

- (IBAction)didTapShareOnce:(id)sender {
    [KSToastView ks_showToast:@"Shared one location." duration:1.0f];
    updateOnce = true;
    [self checkAlwaysAuthorization];
    [self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.manager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.task = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"Location-send" expirationHandler:^{
        NSLog(@"Expired");
        self.task = UIBackgroundTaskInvalid;
    }];
    NSLog(@"uid: %@", [UserData sharedInstance].uid);
    NSLog(@"username: %@", [UserData sharedInstance].username);
    if ([locations lastObject] != nil) {
        NSLog(@"Location update");
        //NSLog(@"%@", [UserData sharedInstance].number);
        if ([UserData sharedInstance].uid != nil) {
            /*[[self.firebase childByAppendingPath:[NSString stringWithFormat:@"%@/userData", [UserData sharedInstance].uid]] updateChildValues:@{@"test":@"test"} withCompletionBlock:^(NSError *error, Firebase *ref) {
                if (error) {
                    NSLog(@"Error writing to location");
                }
                else {
                    NSLog(@"Successfully wrote to location");
                }
            }];*/
            [self.geofire setLocation:[locations lastObject] forKey:[UserData sharedInstance].uid withCompletionBlock:^(NSError *error) {
                if (error == nil) {
                    NSLog(@"Wrote new location to %@", [UserData sharedInstance].uid);
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

- (IBAction)didTapAdd:(id)sender {
    [kSideMenuController performSegueWithIdentifier:@"ShowAddContactSegue" sender:self];
    /*SDCAlertController *add = [SDCAlertController alertControllerWithTitle:@"Add contact" message:nil preferredStyle:SDCAlertControllerStyleAlert];
    [add addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    UITextField *usernameTextField = ((UITextField *)[[add textFields] objectAtIndex:0]);
    SDCAlertAction *cancel = [SDCAlertAction actionWithTitle:@"Cancel" style:SDCAlertActionStyleCancel handler:nil];
    SDCAlertAction *ok = [SDCAlertAction actionWithTitle:@"Ok" style:SDCAlertActionStyleDefault handler:nil];
    add.shouldDismissBlock = ^BOOL (SDCAlertAction *action) {
        if (action == cancel) {
            return YES;
        }
        else {            
            __block BOOL shouldReturn;
            dispatch_group_t searchGroup = dispatch_group_create();
            dispatch_block_t query = ^{
                dispatch_group_wait(searchGroup, DISPATCH_TIME_FOREVER);
                dispatch_group_enter(searchGroup);
                NSLog(@"Entered");
            
            };
            NSLog(@"Dispatching");
            dispatch_block_wait(query, DISPATCH_TIME_FOREVER);
            NSLog(@"shouldReturn: %d", shouldReturn);
            return shouldReturn;
        }
        return YES;
    };
    [add addAction:cancel];
    [add addAction:ok];
    [self presentViewController:add animated:YES completion:nil];*/
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
    
    else {
        NSLog(@"Authorized");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadView {
    [super loadView];
    [self.importButton removeFromSuperview];
    /*if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self.importButton removeFromSuperview];
    }
    else {
        [self.tableView setHidden:YES];
    }*/
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [kSideMenuController performSegueWithIdentifier:@"ShowLoginSegue" sender:self];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else {
        [[UserData sharedRef] authUser:[UserData sharedInstance].email password:[UserData sharedInstance].password withCompletionBlock:^(NSError *error, FAuthData *authData) {
            if (error) {
                NSLog(@"Error logging in: %@", error);
                if (error.code == -15) {
                    // Internet connection appears to be offline
                }
                [KSToastView ks_showToast:@"Error logging in." duration:1.0f];
            }
            else {
                NSLog(@"Logged in %@ successfully", [UserData sharedInstance].email);
            }
        }];
    }
}

/*- (void)importContacts {
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
    
}*/

/*- (NSString *)formatPhoneNumber:(NSString *)number {
    NSMutableArray *numberArray = [[NSMutableArray alloc] init];//[[NSMutableArray alloc] initWithArray:[number componentsSeparatedByString:@""]];
    for (NSInteger x = 0; x < [number length]; x++) {
        [numberArray addObject:[NSString stringWithFormat:@"%C", [number characterAtIndex:x]]];
    }
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (NSInteger x = 0; x < [numberArray count]; x++) {
        //BEGIN COMMENTif ([numberArray[x] integerValue] == 0) {
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
        }//END COMMENT
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
}*/

/*- (IBAction)didTapImport:(id)sender {
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
}*/

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    [cell.textLabel setText:((FireUser *)[self.contacts objectAtIndex:indexPath.row]).username];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selected = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"ShowMapSegue" sender:[tableView cellForRowAtIndexPath:indexPath]
     ];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowMapSegue"]) {
        [((MapViewController *)[segue destinationViewController]) setRecipientId:((FireUser *)self.contacts[self.selected.row]).uid];
        NSLog(@"sending uid: %@", ((FireUser *)self.contacts[self.selected.row]).uid);
        [[[segue destinationViewController] navigationItem] setTitle:[[sender textLabel] text]];
    }
}

@end

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
#import "GeoFire+Private.h"
//#import <SDCAlertController.h>
#import <UITextField+Shake/UITextField+Shake.h>
#import "KSToastView.h"
#import "RSTToastView.h"
#import "FirebaseHelper.h"
#import "SCAHelper.h"
#import "LocationDelegate.h"
@import AddressBook;

//#define kPinpointURL @"pinpoint.firebaseio.com"

@interface ContactsViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sharingButton;
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) RSTToastView *toastView;
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
    if ([[LocationDelegate sharedInstance] isRunning]) {
        self.sharingButton.title = @"Stop Sharing";
    }
    else {
        self.sharingButton.title = @"Start Sharing";
    }
    self.toastView = [[RSTToastView alloc] initWithMessage:@""];
    self.toastView.tintColor = [UIColor colorWithRed:(43.0/255.0) green:(65.0/255.0) blue:(98.0/255.0) alpha:1.0f];
    NSData *contactsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"contacts"];
    if (contactsData) {
        self.contacts = [NSKeyedUnarchiver unarchiveObjectWithData:contactsData];
    }
    if (!self.contacts) {
        self.contacts = [[NSMutableArray alloc] init];
    }
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.tableView];
    }
    /*if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [self importContacts];
    }*/
    //self.firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"pinpoint.firebaseio.com/locations/%@", [UserData sharedInstance].uid]];
    // Register observer for contacts being added
    [AddViewController registerObserver:^(NSNotification *note) {
        if (note.name != ContactsChangedNotification) {
            return;
        }
        self.contacts = note.object;
        [self.tableView reloadData];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:self.contacts] forKey:@"contacts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    // Do any additional setup after loading the view.
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    MapViewController *mapVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mapVC"];
    UITableViewCell *tappedCell = (UITableViewCell *)[self.view hitTest:location withEvent:nil].superview;//(UITableViewCell *)[self visibleViewAtPoint:location];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    mapVC.recipientId = ((FireUser *)self.contacts[indexPath.row]).uid;
    mapVC.navigationItem.title = tappedCell.textLabel.text;
    return mapVC;
}

- (void) findView:(UIView**)visibleView atPoint:(CGPoint)pt fromParent:(UIView*)parentView {
    UIView *applicationWindowView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
    
    if(parentView == nil) {
        parentView = applicationWindowView;
    }
    
    for(UIView *view in parentView.subviews)
    {
        if((view.superview != nil) && (view.hidden == NO) && (view.alpha > 0))
        {
            CGPoint pointInView = [applicationWindowView convertPoint:pt toView:view];
            
            if([view pointInside:pointInView withEvent:nil]) {
                *visibleView = view;
            }
            
            [self findView:visibleView atPoint:pt fromParent:view];
        }
    }
}

- (UIView*) visibleViewAtPoint:(CGPoint)pt {
    UIView *visibleView = nil;
    [self findView:&visibleView atPoint:pt fromParent:nil];
    
    return visibleView;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:@selector(openLeftView)];
}

- (IBAction)openLeftView:(id)sender {
    [kSideMenuController showLeftViewAnimated:YES completionHandler:nil];
}

- (IBAction)didTapShare:(id)sender {
    updateOnce = false;
    if ([self.sharingButton.title isEqualToString:@"Start Sharing"]) {
        [self changePrivacySettingsWithCompletion:^{
            NSLog(@"completed");
            sca_dispatch_sync_on_main_thread(^{
                if (!self.toastView.isVisible) {
                    self.toastView.message = @"Started sharing location";
                    [self.toastView showForDuration:1.0f];
                }
            });
            //[KSToastView ks_showToast:@"Started sharing location." duration:1.0f];
            self.sharingButton.title = @"Stop Sharing";
            [self checkAlwaysAuthorization];
            //[self.manager startUpdatingLocation];
            [[LocationDelegate sharedInstance] beginUpdates];
        }];
    }
    else {
        sca_dispatch_sync_on_main_thread(^{
            if (!self.toastView.isVisible) {
                self.toastView.message = @"Stopped sharing location";
                [self.toastView showForDuration:1.0f];
            }
        });
        //[KSToastView ks_showToast:@"Stopped sharing location." duration:1.0f];
        self.sharingButton.title = @"Start Sharing";
        [[LocationDelegate sharedInstance] endUpdates];
        //[self.manager stopUpdatingLocation];
        //[NSObject cancelPreviousPerformRequestsWithTarget:self.manager];
    }
}

// TODO: Use [self.manager requestLocation];
- (IBAction)didTapShareOnce:(id)sender {
    [self changePrivacySettingsWithCompletion:^{
        sca_dispatch_sync_on_main_thread(^{
            if (!self.toastView.isVisible) {
                self.toastView.message = @"Shared one location.";
                [self.toastView showForDuration:1.0f];
            }
        });
        //[KSToastView ks_showToast:@"Shared one location." duration:1.0f];
        updateOnce = true;
        [self checkAlwaysAuthorization];
        //[self.manager setDesiredAccuracy:kCLLocationAccuracyBest];
        //[self.manager startUpdatingLocation];
        [[LocationDelegate sharedInstance] updateOnce];
    }];
}

typedef void(^completionBlock)(void);
completionBlock changeSettingsBlock;
- (void)changePrivacySettingsWithCompletion:(completionBlock)block {
    NSInteger value = [[NSUserDefaults standardUserDefaults] integerForKey:@"privacySettingValue"];
    if (value == 0) {
        [FirebaseHelper updateReadRules:[[NSUserDefaults standardUserDefaults] objectForKey:@"defaultLocationViewers"]];
        block();
    }
    else if (value == 1) {
        changeSettingsBlock = block;
        SHMultipleSelect *multipleSelect = [[SHMultipleSelect alloc] init];
        multipleSelect.delegate = self;
        multipleSelect.rowsCount = [self.contacts count];
        [multipleSelect show];
    }
}

- (void)multipleSelectView:(SHMultipleSelect*)multipleSelectView clickedBtnAtIndex:(NSInteger)clickedBtnIndex withSelectedIndexPaths:(NSArray *)selectedIndexPaths {
    // Gets all selected users and saves them to "approvedLocationViewers" in NSUserDefaults
    if (clickedBtnIndex == 1) { // Done button
        NSMutableArray *selectedUsers = [[NSMutableArray alloc] initWithCapacity:[selectedIndexPaths count]];
        for (NSInteger x = 0; x < [selectedIndexPaths count]; x++) {
            selectedUsers[x] = ((FireUser *)self.contacts[((NSIndexPath *)selectedIndexPaths[x]).row]).uid;
        }
        [FirebaseHelper updateReadRules:selectedUsers];
        changeSettingsBlock();
    }
}

- (NSString*)multipleSelectView:(SHMultipleSelect*)multipleSelectView titleForRowAtIndexPath:(NSIndexPath*)indexPath {
    return ((FireUser *)self.contacts[indexPath.row]).username;
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
    self.manager = [[CLLocationManager alloc] init];
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


// TODO: Don't log in every time the view is shown
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loggedIn" object:nil];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
        [kSideMenuController performSegueWithIdentifier:@"ShowLoginSegue" sender:self];
    }
    else {
        [FirebaseHelper authWithEmail:[UserData sharedInstance].email password:[UserData sharedInstance].password completion:^(FIRUser *user, NSError *error) {
            if (error) {
                NSLog(@"Error logging in: %@", error);
                if (error.code == -15) {
                    // Internet connection appears to be offline
                }
                sca_dispatch_sync_on_main_thread(^{
                    if (!self.toastView.isVisible) {
                        self.toastView.message = @"Error logging in";
                        [self.toastView showForDuration:1.0f];
                    }
                });
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"loggedIn" object:nil];
                //[KSToastView ks_showToast:@"Error logging in." duration:1.0f];
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

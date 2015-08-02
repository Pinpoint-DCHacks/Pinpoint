//
//  MapViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/1/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>

#define kFirechatNS @"pinpoint.firebaseIO.com"

@interface MapViewController ()
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) FDataSnapshot *lastData;
@end

@implementation MapViewController

BOOL allowed = false;
UIAlertController *waitAlert;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    self.number = [[NSUserDefaults standardUserDefaults] objectForKey:@"number"];
    self.firebase = [[Firebase alloc] initWithUrl:kFirechatNS];
    // Setup bar button item
    MKUserTrackingBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[self.toolbar items]];
    [items insertObject:trackingButton atIndex:0];
    [self.toolbar setItems:items];
    // Location manager
    self.manager = [[CLLocationManager alloc] init];
    [self checkAlwaysAuthorization];
    // Firebase
    [self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"--------------- %@", self.name);
        NSLog(@"Recieved message");
        NSLog(@"reciever %@", snapshot.value[@"reciever-number"]);
        NSLog(@"self.number: %@, recipient number: %@", self.number, self.recipientNumber);
        if ([snapshot.value[@"reciever-number"] isEqualToString:self.number]) {
            NSLog(@"Processing");
            if ([snapshot.value[@"request"] isEqualToString:@"location"]) {
                NSLog(@"LOCATION REQUEST");
                if (!allowed) {
                    NSLog(@"REQUESTING PERMISSON TO VIEW LOCATION");
                    UIAlertController *allow = [UIAlertController alertControllerWithTitle:@"Location requested" message:[NSString stringWithFormat:@"%@ would like to find you.", snapshot.value[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *deny = [UIAlertAction actionWithTitle:@"Deny" style:UIAlertActionStyleCancel handler:nil];
                    UIAlertAction *accept = [UIAlertAction actionWithTitle:@"Allow" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self.manager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
                    [self.manager startUpdatingLocation];
                    }];
                    [allow addAction:deny];
                    [allow addAction:accept];
                    [self presentViewController:allow animated:YES completion:nil];
                }
                else {
                    NSLog(@"STARTING LOCATION UPDATES");
                    [self.manager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
                    [self.manager startUpdatingLocation];
                }
            }
            else if ([snapshot.value[@"request"] isEqualToString:@"response"]) {
                NSLog(@"LOCATION RECIEVED");
                [waitAlert dismissViewControllerAnimated:YES completion:nil];
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                [annotation setCoordinate:((CLLocation *)snapshot.value[@"data"]).coordinate];
                [self.mapView addAnnotation:annotation];
            }
        }
    }];
    // Send location request
    [[self.firebase childByAutoId] setValue:@{@"sender-number": self.number, @"reciever-number": self.recipientNumber, @"request": @"location", @"name": self.name}];
    waitAlert = [UIAlertController alertControllerWithTitle:@"Please wait" message:@"Requesting permission to view location." preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:waitAlert animated:YES completion:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"LOCATION UPDATE");
    [[self.firebase childByAutoId] setValue:@{@"sender-number": self.lastData.value[@"reciever-number"], @"reciever-number": self.lastData.value[@"sender-number"], @"request": @"response", @"name": self.name, @"data": (CLLocation *)[locations lastObject]}];
    [self.manager stopUpdatingLocation];
}

- (void)checkAlwaysAuthorization {
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
        if([self.manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.manager requestAlwaysAuthorization];
        }
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

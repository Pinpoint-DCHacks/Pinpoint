//
//  MapViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/1/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "MapViewController.h"
//#import <CoreLocation/CoreLocation.h>
#import <Firebase/Firebase.h>
#import <GeoFire/GeoFire+Private.h>

#define kPinpointURL @"pinpoint.firebaseIO.com"

@interface MapViewController ()
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) GeoFire *geofire;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *number;
@end

@implementation MapViewController

BOOL allowed = false;
UIAlertController *waitAlert;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self checkAlwaysAuthorization];
    self.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    self.number = [[NSUserDefaults standardUserDefaults] objectForKey:@"number"];
    self.firebase = [[Firebase alloc] initWithUrl:kPinpointURL];
    self.geofire = [[GeoFire alloc] initWithFirebaseRef:self.firebase];
    
    // Setup bar button item
    MKUserTrackingBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[self.toolbar items]];
    [items insertObject:trackingButton atIndex:0];
    [self.toolbar setItems:items];
    [self startRefreshingLocation];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startRefreshingLocation {
    NSLog(@"Refreshing location");
    NSLog(@"%@", self.recipientNumber);
    [self.geofire getLocationForKey:self.recipientNumber withCallback:^(CLLocation *location, NSError *error) {
        NSLog(@"Getting location");
        if (error == nil) {
            NSLog(@"Location successfully tranferred");
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            [annotation setCoordinate:location.coordinate];
            [annotation setTitle:@"Last location"];
            [self removeAllAnnotations];
            [self.mapView addAnnotation:annotation];
        }
        else {
            NSLog(@"Error fetching location %@", error);
        }
    }];
    [self performSelector:@selector(startRefreshingLocation) withObject:nil afterDelay:5];
}

- (void)stopRefreshingLocation {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)removeAllAnnotations {
    id userLocation = [self.mapView userLocation];  // Current location
    NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.mapView annotations]];   // All annotations on the map
    if (userLocation != nil) {
        [pins removeObject:userLocation]; // Remove user location from the annotations
    }
    [self.mapView removeAnnotations:pins];
    // Removes all annotations from the mapview, excluding user location
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"LOCATION UPDATE");
    
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
        [self presentViewController:alertController animated:YES completion:nil];
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

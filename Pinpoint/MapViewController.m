//
//  MapViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/1/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "MapViewController.h"
#import <Firebase/Firebase.h>
#import <GeoFire/GeoFire+Private.h>

#define kPinpointURL @"pinpoint.firebaseIO.com"

@interface MapViewController ()
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) Firebase *firebase;
@property (strong, nonatomic) GeoFire *geofire;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *number;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@end

@implementation MapViewController

BOOL allowed = false;
UIAlertController *waitAlert;
MKPointAnnotation *annotation;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [[CLLocationManager alloc] init];
    [self.manager setDelegate:self];
    annotation = [[MKPointAnnotation alloc] init];
    [self.mapView addAnnotation:annotation];
    self.name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    self.number = [[NSUserDefaults standardUserDefaults] objectForKey:@"number"];
    self.firebase = [[Firebase alloc] initWithUrl:kPinpointURL];
    self.geofire = [[GeoFire alloc] initWithFirebaseRef:self.firebase];
    
    // Setup bar button item
    MKUserTrackingBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[self.toolbar items]];
    [items insertObject:trackingButton atIndex:0];
    [self.toolbar setItems:items];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkAlwaysAuthorization];
    [self startRefreshingLocation];
}

- (void)startRefreshingLocation {
    NSLog(@"Refreshing location");
    NSLog(@"%@", self.recipientNumber);
    [self.geofire getLocationForKey:self.recipientNumber withCallback:^(CLLocation *location, NSError *error) {
        NSLog(@"Getting location");
        if (error == nil) {
            NSLog(@"Location successfully tranferred");
            // Annotation
            [UIView beginAnimations:nil context:NULL]; // animate the following:
            annotation.coordinate = location.coordinate; // move to new location
            [UIView setAnimationDuration:2.0f];
            [UIView commitAnimations];
            /*[UIView animateWithDuration:2.0f animations:^{
                annotation.coordinate = location.coordinate;
            } completion:nil];*/
            //[annotation setCoordinate:location.coordinate];
            [annotation setTitle:@"Last location"];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateStyle:NSDateFormatterNoStyle];
            [df setTimeStyle:NSDateFormatterMediumStyle];
            [annotation setSubtitle:[df stringFromDate:location.timestamp]];
            //[self removeAllAnnotations];
            
            
            // Distance label
            CLLocation *currentLocation = self.mapView.userLocation.location;
            [self.distanceLabel setText:[NSString stringWithFormat:@"%.02f meters", [currentLocation distanceFromLocation:location]]];
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
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    else if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"Not determined");
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

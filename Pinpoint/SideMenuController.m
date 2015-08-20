//
//  SideMenuController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/14/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "SideMenuController.h"
#import "AppDelegate.h"
#import "LeftTableViewController.h"
#import "FireUser.h"
#import "ContactsViewController.h"
#import "MapViewController.h"
#import "AddViewController.h"

#define rootView ((ContactsViewController *)[((UINavigationController *)self.rootViewController).viewControllers objectAtIndex:0])

@interface SideMenuController ()
@property (strong, nonatomic) LeftTableViewController *leftViewController;
@end

@implementation SideMenuController
CGRect frame;
CGRect bounds;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.rootViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
    self.leftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LeftTableViewController"];
    [self setLeftViewEnabledWithWidth:250.f
                    presentationStyle:LGSideMenuPresentationStyleScaleFromBig
                 alwaysVisibleOptions:0];
    
    self.leftViewStatusBarVisibleOptions = LGSideMenuStatusBarVisibleOnNone;
    
    //self.leftViewBackgroundColor = [UIColor colorWithWhite:1.f alpha:0.9];
    
    self.leftViewController.tableView.backgroundColor = [UIColor clearColor];
    [self.leftView addSubview:self.leftViewController.tableView];
    
    frame = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.frame;
    bounds = ((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.bounds;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftViewWillShow) name:kLGSideMenuControllerWillShowLeftViewNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftViewWillHide) name:kLGSideMenuControllerWillDismissLeftViewNotification object:nil];
}

- (void)leftViewWillShow {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.window.clipsToBounds = YES;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        appDelegate.window.frame =  CGRectMake(20, 0,appDelegate.window.frame.size.width-20,appDelegate.window.frame.size.height);
        appDelegate.window.bounds = CGRectMake(20, 0, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height);
    } else
    {
        appDelegate.window.frame =  CGRectMake(0,20,appDelegate.window.frame.size.width,appDelegate.window.frame.size.height-20);
        appDelegate.window.bounds = CGRectMake(0, 20, appDelegate.window.frame.size.width, appDelegate.window.frame.size.height);
    }
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
}

- (void)leftViewWillHide {
    
}

- (void)leftViewWillLayoutSubviewsWithSize:(CGSize)size {
    [super leftViewWillLayoutSubviewsWithSize:size];
    self.leftViewController.tableView.frame = CGRectMake(0.f , 0.f, size.width, size.height);
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowAddContactSegue"]) {
        [((AddViewController *)[[[segue destinationViewController] viewControllers] objectAtIndex:0]) setContacts:rootView.contacts];
    }
}

@end

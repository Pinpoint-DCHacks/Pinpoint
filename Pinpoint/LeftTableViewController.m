//
//  LeftTableViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/14/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "LeftTableViewController.h"
#import "AppDelegate.h"
#import "LeftViewCell.h"
#import "UserData.h"

@interface LeftTableViewController ()

@end

@implementation LeftTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [[UserData sharedInstance] load];
#warning Doesn't work first time
    if ([UserData sharedInstance].username != nil) {
        self.titlesArray = @[[UserData sharedInstance].username,
                             @"",
                             @"Contacts",
                             @"Profile",
                             @"Groups",
                             @"Privacy"];
    }
    else {
        _titlesArray = @[@"Pinpoint",
                         @"",
                         @"Contacts",
                         @"Profile",
                         @"Groups",
                         @"Privacy"];
    }
    [[NSNotificationCenter defaultCenter] addObserverForName:@"loggedIn" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        [[UserData sharedInstance] load];
        if ([UserData sharedInstance].username != nil) {
            self.titlesArray = @[[UserData sharedInstance].username,
                                 @"",
                                 @"Contacts",
                                 @"Profile",
                                 @"Groups",
                                 @"Privacy"];
            [self.tableView reloadData];
        }
    }];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(20.f, 0.f, 20.f, 0.f);
    self.tableView.showsVerticalScrollIndicator = NO;
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titlesArray.count;
}

#pragma mark - UITableView Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeftViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.textLabel.text = _titlesArray[indexPath.row];
    cell.separatorView.hidden = !(indexPath.row != _titlesArray.count-1 && indexPath.row != 1/* && indexPath.row != 2*/);
    cell.userInteractionEnabled = (indexPath.row != 1  && indexPath.row != 0);
    
    cell.tintColor = [UIColor whiteColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) return 22.f;
    else return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *newView;
    if (indexPath.row == 2) {
        newView = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ContactsNavController"];
    }
    else if (indexPath.row == 4) {
        newView = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GroupsNavController"];
    }
    else if (indexPath.row == 5) {
        newView = (UINavigationController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyNavController"];
    }
    
    [self performSelector:@selector(hideLeftView) withObject:nil afterDelay:0/*.25*/];
    kSideMenuController.rootViewController = newView;
    /*if (indexPath.row == 0)
     {
     ViewController *viewController = [kNavigationController viewControllers].firstObject;
     
     UIViewController *viewController2 = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
     viewController2.title = @"Test";
     
     [kNavigationController setViewControllers:@[viewController, viewController2]];
     
     [kMainViewController hideLeftViewAnimated:YES completionHandler:nil];
     }
     else if (indexPath.row == 1)
     {
     if (![kMainViewController isLeftViewAlwaysVisible])
     {
     [kMainViewController hideLeftViewAnimated:YES completionHandler:^(void)
     {
     [kMainViewController showRightViewAnimated:YES completionHandler:nil];
     }];
     }
     else [kMainViewController showRightViewAnimated:YES completionHandler:nil];
     }
     else
     {
     UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
     viewController.title = _titlesArray[indexPath.row];
     [kNavigationController pushViewController:viewController animated:YES];
     
     [kMainViewController hideLeftViewAnimated:YES completionHandler:nil];
     }*/
}

- (void)hideLeftView {
    [kSideMenuController hideLeftViewAnimated:YES completionHandler:nil];
}

@end
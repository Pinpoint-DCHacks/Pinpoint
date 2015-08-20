//
//  PrivacyViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/20/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "PrivacyViewController.h"
#import "AppDelegate.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openLeftView:(id)sender {
    [kSideMenuController showLeftViewAnimated:YES completionHandler:nil];
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

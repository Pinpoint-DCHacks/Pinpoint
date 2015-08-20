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
@property (nonatomic) NSInteger privacyValue;
@property (strong, nonatomic) UISegmentedControl *privacyControl;
@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.privacyValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"privacySettingValue"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)openLeftView:(id)sender {
    [kSideMenuController showLeftViewAnimated:YES completionHandler:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Title";
    }
    else if (section == 1) {
        return @"Title2";
    }
    return nil;
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if ([indexPath indexAtPosition:0] == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cellID%ld", (long)indexPath.row]];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] init];
        }
        if (indexPath.row == 1) {
            self.privacyControl = [[UISegmentedControl alloc] initWithItems:@[@"Use Default", @"Ask"]];
            CGFloat cellWidth = cell.frame.size.width;
            self.privacyControl.frame = CGRectMake((cellWidth - (cellWidth - 65)) / 2, (cell.frame.size.height - 29) / 2, cellWidth - 65, 29);
            self.privacyControl.selectedSegmentIndex = self.privacyValue;
            [self.privacyControl addTarget:self action:@selector(didTapPrivacyControl) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:self.privacyControl];
        }
    }
    else {
        cell = [[UITableViewCell alloc] init];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Default";
        }
    }
    return cell;
}

- (void)didTapPrivacyControl {
    self.privacyValue = self.privacyControl.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:self.privacyControl.selectedSegmentIndex forKey:@"privacySettingValue"];
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

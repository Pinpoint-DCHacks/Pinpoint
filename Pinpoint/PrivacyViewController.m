//
//  PrivacyViewController.m
//  Pinpoint
//
//  Created by Spencer Atkin on 8/20/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import "PrivacyViewController.h"
#import "AppDelegate.h"
#import "FireUser.h"

@interface PrivacyViewController ()
@property (nonatomic) NSInteger privacyValue;
@property (strong, nonatomic) UISegmentedControl *privacyControl;
@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSArray *dataSource;
@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSData *contactsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"contacts"];
    if (contactsData) {
        self.contacts = [NSKeyedUnarchiver unarchiveObjectWithData:contactsData];
    }
    if (!self.contacts) {
        self.contacts = [[NSMutableArray alloc] init];
    }
    if (!self.dataSource) {
        self.dataSource = [[NSArray alloc] init];
    }
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
            self.privacyControl = cell.contentView.subviews[0];
            self.privacyControl.selectedSegmentIndex = self.privacyValue;
            [self.privacyControl addTarget:self action:@selector(didTapPrivacyControl) forControlEvents:UIControlEventValueChanged];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath indexAtPosition:0] == 1) {
        SHMultipleSelect *multipleSelect = [[SHMultipleSelect alloc] init];
        multipleSelect.delegate = self;
        if (indexPath.row == 0) {
            self.dataSource = (NSArray *)self.contacts;
        }
        multipleSelect.rowsCount = self.dataSource.count;
        [multipleSelect show];
    }
}

#pragma mark - SHMultipleSelectDelegate
- (void)multipleSelectView:(SHMultipleSelect*)multipleSelectView clickedBtnAtIndex:(NSInteger)clickedBtnIndex withSelectedIndexPaths:(NSArray *)selectedIndexPaths {
    if (clickedBtnIndex == 1) { // Done btn
        for (NSIndexPath *indexPath in selectedIndexPaths) {
            NSLog(@"%@", ((FireUser *)self.dataSource[indexPath.row]).username);
        }
    }
}

- (NSString*)multipleSelectView:(SHMultipleSelect*)multipleSelectView titleForRowAtIndexPath:(NSIndexPath*)indexPath {
    return ((FireUser *)self.dataSource[indexPath.row]).username;
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

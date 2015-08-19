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
@property (strong, nonatomic) NSArray *titlesArray;
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
    NSLog(@"LeftViewController awakeFromNib");
    [super awakeFromNib];
    
    [[UserData sharedInstance] load];
    _titlesArray = @[[UserData sharedInstance].username,
                     @"Open Right View",
                     @"",
                     @"Profile",
                     @"News",
                     @"Articles",
                     @"Video",
                     @"Music"];
    
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
    cell.separatorView.hidden = !(indexPath.row != _titlesArray.count-1 && indexPath.row != 1 && indexPath.row != 2);
    cell.userInteractionEnabled = (indexPath.row != 2);
    
    cell.tintColor = [UIColor whiteColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2) return 22.f;
    else return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"NavigationController"];
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

/*- (void)viewDidLoad {
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

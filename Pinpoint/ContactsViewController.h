//
//  ContactsViewController.h
//  Pinpoint
//
//  Created by Spencer Atkin on 8/1/15.
//  Copyright (c) 2015 Pinpoint-DCHacks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMPhoneFormat.h"
#import <SHMultipleSelect/SHMultipleSelect.h>

@interface ContactsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, SHMultipleSelectDelegate, UIViewControllerPreviewingDelegate>
@property (weak, nonatomic) IBOutlet UIButton *importButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSIndexPath *selected;
@end

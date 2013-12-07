//
//  MasterViewController.h
//  ContactBrowser
//
//  Created by Chris Anderson on 12/4/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Couchbaselite/CBLUITableSource.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (nonatomic) IBOutlet CBLUITableSource* dataSource;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

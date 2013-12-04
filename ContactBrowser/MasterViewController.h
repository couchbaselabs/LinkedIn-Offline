//
//  MasterViewController.h
//  ContactBrowser
//
//  Created by Chris Anderson on 12/4/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end

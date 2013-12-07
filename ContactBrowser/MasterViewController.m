//
//  MasterViewController.m
//  ContactBrowser
//
//  Created by Chris Anderson on 12/4/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"

#import <CouchbaseLite/CouchbaseLite.h>
#import "AppSecretConfig.h"
#import "Contact.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController{
    AppDelegate *app;
}

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.


//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    app = [[UIApplication sharedApplication] delegate];
    NSAssert(_dataSource, @"_dataSource not connected");
    _dataSource.query = [Contact queryContactsInDatabase: app.database].asLiveQuery;
    _dataSource.labelProperty = @"name";    // Document property to display in the cell label
    if (!app.cblSync.userID) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonSystemItemRefresh target:self action:@selector(didPressLogin:)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Linked-In Login

- (void)didPressLogin:(id)sender
{
    [app loginAndSync:^{
        NSLog(@"we are syncing");
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

// Delegate method called when the live-query results change.
- (void)couchTableSource:(CBLUITableSource*)source
         updateFromQuery:(CBLLiveQuery*)query
            previousRows:(NSArray *)previousRows
{
    //    NSLog(@"couchTableSource previousRows %@",previousRows);
    
    [[self tableView] reloadData];
    
    //    if (!_initialLoadComplete) {
    //        // On initial table load on launch, decide which row/list to select:
    //        [self selectList: self.initialList];
    //        _initialLoadComplete = YES;
    //    }
}


#pragma mark - Table View

// Delegate method to set up a new table cell
- (void)couchTableSource:(CBLUITableSource*)source
             willUseCell:(UITableViewCell*)cell
                  forRow:(CBLQueryRow*)row
{
     Contact* contact = [Contact modelForDocument: row.document];
    if (contact.avatar) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
}
//todo call this from the table view
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //        NSDate *object = _objects[indexPath.row];
        CBLQueryRow *row = [self.dataSource rowAtIndex:indexPath.row];
        Contact* contact = [Contact modelForDocument: row.document];
        self.detailViewController.detailItem = contact;
        NSLog(@"didSelectRowAtIndexPath contact %@",contact.description);
        
        
        //        [self showList: list];
        
    } else {
        [self performSegueWithIdentifier:@"showDetail" sender:self];
    }
}

@end

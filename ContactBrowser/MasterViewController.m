//
//  MasterViewController.m
//  ContactBrowser
//
//  Created by Chris Anderson on 12/4/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInHttpClient.h"

#define kAuthAgentServer @"http://10.0.1.12:8080"

@interface MasterViewController () {
    NSMutableArray *_objects;
    LIALinkedInHttpClient *_client;
}
@end

@implementation MasterViewController

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
    
    
    NSArray *grantedAccess = @[@"r_fullprofile", @"r_network", @"w_messages", @"r_emailaddress"];
    
    //load the the secret data from an uncommitted LIALinkedInClientExampleCredentials.h file
    NSString *clientId = @"75pagpxz73rdcs"; //the client secret you get from the registered LinkedIn application
    NSString *clientSecret = @"krsIJQtDU5cAZMO4"; //the client secret you get from the registered LinkedIn application
    NSString *state = @"entropy8please34876tfgkshd7qieufg28734ythanks"; //A long unique string value of your choice that is hard to guess. Used to prevent CSRF
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:@"http://mobile.couchbase.com" clientId:clientId clientSecret:clientSecret state:state grantedAccess:grantedAccess];
    _client = [LIALinkedInHttpClient clientForApplication:application];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonSystemItemRefresh target:self action:@selector(didPressLogin:)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Linked-In Login

- (void)sendAccessTokenToAuthenticationAgent: (NSString *)accessToken {
    LIALinkedInHttpClient *authAgentClient = [[LIALinkedInHttpClient alloc] initWithBaseURL:[NSURL URLWithString:kAuthAgentServer]];
    [authAgentClient getPath:[@"/_access_token/" stringByAppendingString:accessToken] parameters:nil  success:^(AFHTTPRequestOperation *operation, NSDictionary *userData) {
        NSLog(@"Got userData %@ with accessToken %@", userData, accessToken);
        
//        now we are ready to sync...
        
        
        
    }     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Setting new accessToken failed %@", error);
    }];
}

- (void)didPressLogin:(id)sender
{
    NSLog(@"didPressLogin");
    
    [_client getAuthorizationCode:^(NSString *code) {
        [_client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            
//            todo use the _client to discover email address can be done on the server
            [self sendAccessTokenToAuthenticationAgent: accessToken];
            
            
            [_client getPath:[NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~?oauth2_access_token=%@&format=json", accessToken] parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *result) {
                NSLog(@"current user %@", result);
            }            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"failed to fetch current user %@", error);
            }];
        }                   failure:^(NSError *error) {
            NSLog(@"Quering accessToken failed %@", error);
        }];
    }                          cancel:^{
        NSLog(@"Authorization was cancelled by user");
    }                         failure:^(NSError *error) {
        NSLog(@"Authorization failed %@", error);
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

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *object = _objects[indexPath.row];
    self.detailViewController.detailItem = object;
}

@end

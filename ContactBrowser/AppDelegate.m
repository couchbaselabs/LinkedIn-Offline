//
//  AppDelegate.m
//  ContactBrowser
//
//  Created by Chris Anderson on 12/4/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import "AppDelegate.h"
#import "AppSecretConfig.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    splitViewController.delegate = (id)navigationController.topViewController;
    
    [self setupCBL];
    [self setupCBLSync];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - Public API to Trigger Login and Sync

- (void)loginAndSync: (void (^)())complete {
    if (_cblSync.userID) {
        complete();
    } else {
        [_cblSync beforeFirstSync:^(NSString *userID, NSDictionary *userData, NSError **outError) {
            complete();
        }];
        [_cblSync start];
    }
}

#pragma mark - Setup Couchbase Lite and Linked-In Authentication

- (void) setupCBL {
    CBLManager *manager = [CBLManager sharedInstance];
    NSError *error;
    self.database = [manager databaseNamed: @"linkedin" error: &error];
    if (error) {
        NSLog(@"error getting database %@",error);
        exit(-1);
    }
    
}

- (void) setupCBLSync {
    NSURL *syncURL = [NSURL URLWithString:kSyncRemoteDB relativeToURL:[NSURL URLWithString:kSyncRemoteServer]];
    
    _cblSync = [[CBLSyncManager alloc] initSyncForDatabase:_database withURL:syncURL];
    
    // Tell the Sync Manager to use Facebook for login.
    _cblSync.authenticator = [[CBLLinkedInAuth alloc] initWithClientID:kLIClientID clientSecret:kLIClientSecret redirectURL:kLIRedirectURL];
    
    if (_cblSync.userID) {
        //        we are logged in, go ahead and sync
        [_cblSync start];
    } else {
        // Application callback to create the user profile.
        // this will be triggered after we call [_cblSync start]
        [_cblSync beforeFirstSync:^(NSString *userID, NSDictionary *userData,  NSError **outError) {
            // This is a first run, setup the profile but don't save it yet.
            NSLog(@"about to sync");
        }];
    }
}



@end

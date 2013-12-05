//
//  AppDelegate.h
//  ContactBrowser
//
//  Created by Chris Anderson on 12/4/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBLSyncManager.h"
#import "CBLLinkedInAuth.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CBLDatabase *database;
@property (strong, nonatomic) CBLSyncManager *cblSync;

- (void)loginAndSync: (void (^)())complete;

@end

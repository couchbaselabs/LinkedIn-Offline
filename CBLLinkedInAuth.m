//
//  CBLLinkedInAuth.m
//  ContactBrowser
//
//  Created by Chris Anderson on 12/5/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import "CBLLinkedInAuth.h"

@implementation CBLLinkedInAuth
@synthesize syncManager=_syncManager;

- (instancetype) initWithAppID:(NSString *)appID {
    self = [super init];
    if (self) {
        _facebookAppID = appID;
    }
    return self;
}

- (void) getCredentials:(void (^)(NSString * userID, NSDictionary * userData))block {
    
}
- (void)registerCredentialsWithReplications:(NSArray *)repls {
    
}
@end


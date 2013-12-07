//
//  CBLLinkedInAuth.m
//  ContactBrowser
//
//  Created by Chris Anderson on 12/5/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import "CBLLinkedInAuth.h"
#import "LIALinkedInApplication.h"
#import "LIALinkedInHttpClient.h"

NSString* CBLLinkedInUUIDString() {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (NSString *)CFBridgingRelease(string);
}

@implementation CBLLinkedInAuth {
    NSString *clientID;
    NSString *clientSecret;
    NSString *clientNonce;
    NSString *redirectURL;
    NSArray *grantedAccess;
    BOOL gettingCredentials;
    LIALinkedInHttpClient *client;
}

@synthesize syncManager=_syncManager;

- (instancetype) initWithClientID:(NSString *)cID clientSecret:(NSString * )secret redirectURL:(NSString*)url {
    NSArray *access = @[@"r_fullprofile", @"r_network", @"w_messages", @"r_emailaddress"];
    return [self initWithClientID:cID clientSecret:secret redirectURL:url grantedAccess:access];
}

- (instancetype) initWithClientID:(NSString *)cID clientSecret:(NSString * )secret redirectURL:(NSString*)url grantedAccess: (NSArray *)access{
    self = [super init];
    if (self) {
        clientID = cID;
        clientSecret = secret;
        redirectURL = url;
        grantedAccess = access;
        clientNonce = CBLLinkedInUUIDString();
        
        [self createClient];
    }
    return self;
}

- (void) getCredentials:(void (^)(NSString * userID, NSDictionary * userData))block {
    if (gettingCredentials) return;
    NSLog(@"getCredentials");
    
    
    


    
    
    
    gettingCredentials = YES;
    [client getAuthorizationCode:^(NSString *code) {
        [client getAccessToken:code success:^(NSDictionary *accessTokenData) {
            NSString *accessToken = [accessTokenData objectForKey:@"access_token"];
            gettingCredentials = NO;
            [self sendAccessTokenToAuthenticationAgent: accessToken complete:block];
        } failure:^(NSError *error) {
            gettingCredentials = NO;
            NSLog(@"Quering accessToken failed %@", error);
        }];
    } cancel:^{
        gettingCredentials = NO;
        NSLog(@"Authorization was cancelled by user");
    } failure:^(NSError *error) {
        gettingCredentials = NO;
        NSLog(@"Authorization failed %@", error);
    }];
}

- (void) createClient {
    LIALinkedInApplication *application = [LIALinkedInApplication applicationWithRedirectURL:redirectURL clientId:clientID clientSecret:clientSecret state:clientNonce grantedAccess:grantedAccess];
    client = [LIALinkedInHttpClient clientForApplication:application];
}

- (void)sendAccessTokenToAuthenticationAgent: (NSString *)accessToken complete:(void (^)(NSString * userID, NSDictionary * userData))complete {
    LIALinkedInHttpClient *authAgentClient = [[LIALinkedInHttpClient alloc] initWithBaseURL:[self.syncManager.remoteURL baseURL]];
    [authAgentClient getPath:[@"/_access_token/" stringByAppendingString:accessToken] parameters:nil  success:^(AFHTTPRequestOperation *operation, NSDictionary *userData) {
        NSLog(@"Got userData %@ with accessToken %@", userData, accessToken);
        complete(userData[@"userID"], userData);
    }     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Setting new accessToken failed %@", error);
    }];
}


- (void)registerCredentialsWithReplications:(NSArray *)repls {
    // no-op as sending the Access Token to the server is all it takes to
    // set the cookie
}

@end


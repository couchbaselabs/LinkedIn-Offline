//
//  AppSecretConfig.h
//  ContactBrowser
//
//  Created by Chris Anderson on 12/5/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#ifndef ContactBrowser_AppSecretConfig_h
#define ContactBrowser_AppSecretConfig_h

#define kSyncRemoteServer @"http://10.0.1.12:8080"
#define kSyncRemoteDB @"linkedin"

// the URL LinkedIn will redirect the WebView to
#define kLIRedirectURL @"http://mobile.couchbase.com"
//the app id you get from the registered LinkedIn application
#define kLIClientID @"75pagpxz73rdcs"
//the client secret you get from the registered LinkedIn application
#define kLIClientSecret @"krsIJQtDU5cAZMO4"
//A long unique string value of your choice that is hard to guess. Used to prevent CSRF
#define kLIClientNonce @"changeme34876tfgkshd7qieufg28734ythanks"

#endif

//
//  Company.h
//  ContactBrowser
//
//  Created by Chris Anderson on 12/7/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>

@interface Company : NSObject
+ (CBLQuery*) queryCompaniesInDatabase: (CBLDatabase*)db;
@end

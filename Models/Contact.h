//
//  Contact.h
//  ContactBrowser
//
//  Created by Chris Anderson on 12/6/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import <UIKit/UIKit.h>

@interface Contact : CBLModel

+ (CBLQuery*) queryContactsInDatabase: (CBLDatabase*)db;

+ (instancetype) contactInDatabase: (CBLDatabase*)db forUserID: (NSString*)userID;

/** The readwrite full name. */
@property (readwrite) NSString* firstName;

/** The user_id is usually an email address. */
@property (readwrite) NSString* lastName;

/** The type is "contact". */
@property (readwrite) NSString* headline;

@property (readonly) UIImage* avatar;
@property (readonly) NSString* location;

@end

//
//  Message.h
//  ContactBrowser
//
//  Created by Chris Anderson on 12/6/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CouchbaseLite/CouchbaseLite.h>
#import "Contact.h"

@interface Message : CBLModel
- (instancetype) initInDatabase: (CBLDatabase*)database
                   fromSenderID: (NSString*)senderID
                    toRecipient: (Contact*)recipient;

@property (readwrite) NSString* type;
@property (readwrite) NSString* state;
@property (readwrite) NSString* subject;
@property (readwrite) NSString* message;
@property (readwrite) NSString* sender_id;
@property (readwrite) Contact* recipient;
@end

//
//  Message.m
//  ContactBrowser
//
//  Created by Chris Anderson on 12/6/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import "Message.h"

@implementation Message

@dynamic type, state, subject, message, sender_id, recipient;

- (instancetype) initInDatabase: (CBLDatabase*)database
                   fromSenderID: (NSString*)senderID
                    toRecipient: (Contact*)recipient{
    NSAssert(senderID, @"Message must have a sender");
    NSAssert(recipient, @"Message must have a recipient");
    self = [super initWithNewDocumentInDatabase: database];
    if (self) {
        self.sender_id = senderID;
        self.recipient = recipient;
        self.type = @"message";
        self.state = @"new";
    }
    return self;
}
@end

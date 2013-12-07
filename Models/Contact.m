//
//  Contact.m
//  ContactBrowser
//
//  Created by Chris Anderson on 12/6/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import "Contact.h"

@implementation Contact{
    UIImage *_avatar;
}

@dynamic firstName, lastName, headline;

+ (CBLQuery*) queryContactsInDatabase: (CBLDatabase*)db {
    CBLView* view = [db viewNamed: @"contacts"];

    if (!view.mapBlock) {
        // Register the map function, the first time we access the view:
        [view setMapBlock: MAPBLOCK({
            if ([doc[@"type"] isEqualToString:@"contact"]) {
                // Parentheses to appease the C preprocessor
                NSString *name = ([NSString stringWithFormat:@"%@ %@", doc[@"firstName"], doc[@"lastName"]]);
                emit(doc[@"lastName"], @{@"name": name});
            }
        }) reduceBlock: nil version: @"4"]; // bump version any time you change the MAPBLOCK body!
    }
    return [view createQuery];
}

+ (instancetype) contactInDatabase: (CBLDatabase*)db forUserID: (NSString*)userID {
    NSParameterAssert(userID);
    NSString* contactDocId = [@"c:" stringByAppendingString:userID];
    CBLDocument *doc = [db documentWithID: contactDocId];
    return doc ? [Contact modelForDocument: doc] : nil;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}
- (UIImage*) avatar {
    if (!_avatar) {
        CBLAttachment *att = [self attachmentNamed: @"avatar"];
        if (att) {
            _avatar = [[UIImage alloc] initWithData:att.content];
        }
        NSLog(@"pic %@ for att %@", _avatar, [self.document properties][@"_attachments"]);
    }
    return _avatar;
}



@end

//
//  Company.m
//  ContactBrowser
//
//  Created by Chris Anderson on 12/7/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import "Company.h"

@implementation Company

+ (CBLQuery*) queryCompaniesInDatabase: (CBLDatabase*)db {
    CBLView* view = [db viewNamed: @"companies"];
    if (!view.mapBlock) {
        // Register the map function, the first time we access the view:
        [view setMapBlock: MAPBLOCK({
            if ([doc[@"type"] isEqualToString:@"company"]) {
                emit(doc[@"name"], nil);
            }
        }) reduceBlock: nil version: @"4"]; // bump version any time you change the MAPBLOCK body!
    }
    return [view createQuery];
}

@end

//
//  DetailViewController.h
//  ContactBrowser
//
//  Created by Chris Anderson on 12/4/13.
//  Copyright (c) 2013 Chris Anderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end

//
//  DiningViewController.h
//  PennMobile
//
//  Created by Sacha Best on 9/9/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiningTableViewCell.h"

#define kTitleKey @"title"
#define kAddressKey @"address"

@interface DiningViewController : UITableViewController

@property NSArray *venues;

- (bool)loadFromAPI;
- (bool)loadFromAPIwithTarget:(id)target selector:(SEL)selector;
@end

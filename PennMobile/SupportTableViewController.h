//
//  SupportTableViewController.h
//  PennMobile
//
//  Created by Sacha Best on 1/22/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SupportItem.h"
#import "SlideOutMenuViewController.h"

@interface SupportTableViewController : UITableViewController {
    UITapGestureRecognizer *cancelTouches;
}

@property NSArray *contacts;

@end

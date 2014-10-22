//
//  RegistrarTableViewController.h
//  PennMobile
//
//  Created by Sacha Best on 10/14/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"
#import "RegistrarTableViewCell.h"

#define REGISTRAR_PATH @"registrar/search?q="

@interface RegistrarTableViewController : UITableViewController <UISearchBarDelegate> {
    UIActivityIndicatorView *activityIndicator;
    NSMutableOrderedSet *tempSet;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSArray *courses;

@end

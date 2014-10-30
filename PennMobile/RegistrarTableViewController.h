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
#import "DetailViewController.h"
#import "MBProgressHUD.h"

#define REGISTRAR_PATH @"registrar/search?q="

@interface RegistrarTableViewController : UITableViewController <UITableViewDelegate, UISearchBarDelegate> {
    UIActivityIndicatorView *activityIndicator;
    NSMutableOrderedSet *tempSet;
    Course *forSegue;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSArray *courses;

@end

//
//  RegistrarTableViewController.h
//  PennMobile
//
//  Created by Sacha Best on 10/14/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Course.h"
#import "RegistrarTableViewCell.h"
#import "DetailViewController.h"
#import "PennTableViewController.h"

#define REGISTRAR_PATH @"registrar/search?q="
#define BUILDING_PATH @"buildings/"

@interface RegistrarTableViewController : PennTableViewController <UITableViewDelegate, UISearchBarDelegate> {
    NSIndexPath *selected;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

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
#import "PCRAggregator.h"

#define REGISTRAR_PATH @"registrar/search?q="
#define BUILDING_PATH @"buildings/search?q="

@interface RegistrarTableViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate,
                                                            UIToolbarDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchBar *registrySearchBar;

@end

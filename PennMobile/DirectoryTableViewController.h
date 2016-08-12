//
//  DirectoryTableViewController.h
//  PennMobile
//
//  Created by Sacha Best on 9/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Person.h"
#import "DetailViewController.h"
#import "PennTableViewController.h"

#define DIRECTORY_PATH @"directory/search?name="
#define DETAIL_PATH @"directory/person/"

@interface DirectoryTableViewController : UIViewController
    <UISearchBarDelegate, ABNewPersonViewControllerDelegate, UIAlertViewDelegate,
     UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchBar *directorySearchBar;

@end

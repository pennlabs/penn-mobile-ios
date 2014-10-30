//
//  DirectoryTableViewController.h
//  PennMobile
//
//  Created by Sacha Best on 9/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Person.h"
#import "PersonTableViewCell.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"

#define DIRECTORY_PATH @"directory/search?name="
#define DETAIL_PATH @"directory/person/"

@interface DirectoryTableViewController : UITableViewController <UISearchBarDelegate> {
    NSMutableOrderedSet *tempSet;
    UIActivityIndicatorView *activityIndicator;
    Person *forSegue;
}

@property NSArray *people;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

-(NSSet *)searchForName:(NSString *)name;
-(NSDictionary *)requetPersonDetails:(NSString *)name;
- (Person *)parsePersonData:(NSDictionary *)data;

@end

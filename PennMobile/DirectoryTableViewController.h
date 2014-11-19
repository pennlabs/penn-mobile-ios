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
#import "PennTableViewController.h"

#define DIRECTORY_PATH @"directory/search?name="
#define DETAIL_PATH @"directory/person/"

@interface DirectoryTableViewController : PennTableViewController <UISearchBarDelegate> {

}

-(NSArray *)searchForName:(NSString *)name;
-(NSDictionary *)requetPersonDetails:(NSString *)name;
- (Person *)parsePersonData:(NSDictionary *)data;

@end

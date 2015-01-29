//
//  PennTableViewController.h
//  PennMobile
//
//  Created by Sacha Best on 11/18/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "SlideOutMenuViewController.h"

@interface PennTableViewController : UIViewController <UISearchBarDelegate> {
    NSMutableOrderedSet *tempSet;
    UITapGestureRecognizer *cancelTouches;
}

@property NSArray *objects;
@property NSObject *forSegue;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (NSArray *)searchFor:(NSString *)name split:(BOOL)split;
- (NSDictionary *)requestDetail:(NSString *)name;
- (NSObject *)parseData:(NSDictionary *)data;
- (void)importData:(NSArray *)data;
- (NSArray *)queryAPI:(NSString *)term;
- (void)queryHandler:(NSString *)search;

- (void)dismissKeyboard:(id)sender;
- (BOOL)confirmConnection:(NSData *)data;
- (void)reloadView;
- (void)searchTemplate;
@end

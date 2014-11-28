//
//  PennTableViewController.h
//  PennMobile
//
//  Created by Sacha Best on 11/18/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface PennTableViewController : UITableViewController <UISearchBarDelegate> {
    NSMutableOrderedSet *tempSet;
    UIActivityIndicatorView *activityIndicator;
}

@property NSArray *objects;
@property NSObject *forSegue;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (NSArray *)searchFor:(NSString *)name split:(BOOL)split;
- (NSDictionary *)requestDetail:(NSString *)name;
- (NSObject *)parseData:(NSDictionary *)data;
- (void)importData:(NSArray *)data;
- (NSArray *)queryAPI:(NSString *)term;
- (void)queryHandler:(NSString *)search;

- (void)dismissKeyboard:(id)sender;
- (BOOL)confirmConnection:(NSData *)data;
- (void)reloadView;

@end

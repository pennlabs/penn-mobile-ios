//
//  PennTableViewController.m
//  PennMobile
//
//  Created by Sacha Best on 11/18/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "PennTableViewController.h"

@interface PennTableViewController ()

@end

@implementation PennTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    _searchBar.delegate = self;
    //[self.tableView setTableHeaderView:_searchBar];
    tempSet = [[NSMutableOrderedSet alloc] initWithCapacity:50];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard:(id)sender {
    [_searchBar resignFirstResponder];
}

-(NSArray *)searchFor:(NSString *)name split:(BOOL)split {
    // This is a set because multiple terms qre queried and we don't want duplicate results
    NSMutableSet *results = [[NSMutableSet alloc] init];
    if (split) {
        if ([name rangeOfString:@" "].length != 0) {
            NSArray *split = [name componentsSeparatedByString:@" "];
            if (split.count > 1) {
                for (NSString *queryTerm in split) {
                    if (queryTerm.length > 1) {
                        [results addObjectsFromArray:[self queryAPI:queryTerm]];
                    }
                }
            }
        } else {
            [results addObjectsFromArray:[self queryAPI:name]];
        }
    } else {
        // to support new Directory API
        NSString *filter = [name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        [results addObjectsFromArray:[self queryAPI:[filter stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]];
    }
    return [results allObjects];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _objects.count;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    _objects = [[NSArray alloc] init];
    [self.tableView reloadData];
    [_searchBar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchTemplate];
}
- (void)searchTemplate {
    [_searchBar resignFirstResponder];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.tableView.userInteractionEnabled = NO;
    [self performSelectorInBackground:@selector(queryHandler:) withObject:_searchBar.text];
}
- (void)reloadView {
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.tableView.userInteractionEnabled = YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (BOOL)confirmConnection:(NSData *)data {
    if (!data) {
        UIAlertView *new = [[UIAlertView alloc] initWithTitle:@"Couldn't Connect to API" message:@"We couldn't connect to Penn's API. Please try again later. :(" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [new show];
        return false;
    }
    return true;
}
@end

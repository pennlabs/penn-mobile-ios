//
//  LaundryDetailTableViewController.m
//  PennMobile
//
//  Created by Krishna Bharathala on 11/13/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import "LaundryMidwayTableViewController.h"
#import "LaundryDetailViewController.h"
#import "LaundryTableViewCell.h"

@interface LaundryMidwayTableViewController ()

@end

@implementation LaundryMidwayTableViewController

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [[[[self.laundryList objectAtIndex:0] objectForKey:@"name"] componentsSeparatedByString:@"-"] objectAtIndex:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    [backButtonItem setTintColor:[UIColor whiteColor]];
    
    self.tableView.alwaysBounceVertical = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableView reloadData];
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.laundryList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LaundryTableViewCell *cell = nil;
    
    int aw = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"washers_available"] intValue];
    int ad = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"dryers_available"] intValue];
    int uw = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"washers_in_use"] intValue];
    int ud = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"dryers_in_use"] intValue];
    
    if (!cell) {
        cell = [[LaundryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil available_washers:aw available_dryers:ad unavailable_washers:uw unavailable_dryers:ud];
    }
    cell.nameLabel.text = [[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LaundryDetailViewController *laundryDetailVC = [[LaundryDetailViewController alloc] init];
    laundryDetailVC.indexNumber = [[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"index"];
    laundryDetailVC.houseName = [[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"name"];
    laundryDetailVC.aw = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"washers_available"] intValue];
    laundryDetailVC.ad = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"dryers_available"] intValue];
    laundryDetailVC.uw = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"washers_in_use"] intValue];
    laundryDetailVC.ud = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"dryers_in_use"] intValue];
    
    [self.navigationController pushViewController:laundryDetailVC animated:NO];
}

@end

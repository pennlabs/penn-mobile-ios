//
//  LaundryDetailTableViewController.m
//  PennMobile
//
//  Created by Krishna Bharathala on 11/13/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import "LaundryDetailTableViewController.h"
#import "LaundryDetailViewController.h"
#import "LaundryTableViewCell.h"

@interface LaundryDetailTableViewController ()

@end

@implementation LaundryDetailTableViewController

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = [[[[self.laundryList objectAtIndex:0] objectForKey:@"name"] componentsSeparatedByString:@"-"] objectAtIndex:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.laundryList);
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    [backButtonItem setTintColor:[UIColor redColor]];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    static NSString *cellIdentifier = @"Cell";
    LaundryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"LaundryTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    cell.nameLabel.text = [[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.available_washers = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"washers_available"] intValue];
    cell.available_dryers = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"dryers_available"] intValue];
    cell.unavailable_washers = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"washers_in_use"] intValue];
    cell.unavailable_dryers = [[[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"dryers_in_use"] intValue];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    [cell awakeFromNib];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LaundryDetailViewController *laundryDetailVC = [[LaundryDetailViewController alloc] init];
    laundryDetailVC.indexNumber = [[self.laundryList objectAtIndex:indexPath.row] objectForKey:@"index"];
    
    [self.navigationController pushViewController:laundryDetailVC animated:NO];
}

@end

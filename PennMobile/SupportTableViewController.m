//
//  SupportTableViewController.m
//  PennMobile
//
//  Created by Sacha Best on 1/22/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "SupportTableViewController.h"

@interface SupportTableViewController ()

@end

@implementation SupportTableViewController

-(id) init {
    self = [super init];
    if(self) {
        self.title = @"Emergency";
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255 green:193.0/255 blue:7.0/255 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:revealController
                                                                        action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    SupportItem *pGeneral = [[SupportItem alloc] init];
    pGeneral.name = @"Penn Police General";
    pGeneral.phone = @"(215) 898-7297";
    pGeneral.phoneFiltered = @"2158987297";
    SupportItem *pEmergency = [[SupportItem alloc] init];
    pEmergency.name = @"Police Emergency/MERT";
    pEmergency.phone = @"(215) 573-3333";
    pEmergency.phoneFiltered = @"2155733333";
    SupportItem *pWalk = [[SupportItem alloc] init];
    pWalk.name = @"Penn Walk";
    pWalk.phone = @"215-898-WALK (9255)";
    pWalk.phoneFiltered = @"2158989255";
    SupportItem *pRide = [[SupportItem alloc] init];
    pRide.name = @"Penn Ride";
    pRide.phone = @"215-898-RIDE (7433)";
    pRide.phoneFiltered = @"2158987433";
    SupportItem *hLine = [[SupportItem alloc] init];
    hLine.name = @"Help Line";
    hLine.phone = @"215-898-HELP (4357)";
    hLine.phoneFiltered = @"2158984357";
    SupportItem *caps = [[SupportItem alloc] init];
    caps.name = @"CAPS";
    caps.phone = @"215-898-7021";
    caps.phoneFiltered = @"2158987021";
    SupportItem *special = [[SupportItem alloc] init];
    special.name = @"Special Services";
    special.phone = @"215-898-4481";
    special.phoneFiltered = @"2158984481";
    SupportItem *womens = [[SupportItem alloc] init];
    womens.name = @"Women's Center";
    womens.phone = @"215-898-8611";
    womens.phoneFiltered = @"2158988611";
    SupportItem *shs = [[SupportItem alloc] init];
    shs.name = @"Student Health Services";
    shs.phone = @"215-746-3535";
    shs.phoneFiltered = @"2157463535";
    _contacts = [NSArray arrayWithObjects:pEmergency, pGeneral, pWalk, pRide, hLine, caps, special, womens, shs, nil];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.bounces = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contacts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    SupportItem *c = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = c.name;
    cell.detailTextLabel.text = c.phone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SupportItem *c = _contacts[indexPath.row];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:c.phoneFiltered];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
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

@end

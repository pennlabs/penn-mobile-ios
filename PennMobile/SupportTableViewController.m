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

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    _contacts = [NSArray arrayWithObjects:pEmergency, pGeneral, pWalk, pRide, hLine, nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UITapGestureRecognizer *taptap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(easterEgg:)];
    taptap.numberOfTapsRequired = 3;
    [self.navigationItem.titleView addGestureRecognizer:taptap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)easterEgg:(id)sender {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:_contacts];
    SupportItem *n = [[SupportItem alloc] init];
    n.name = @"Jake Noonan - Single Rdy 2 Mingle";
    n.phoneFiltered = @"http://pennlabs.org/mobile/easterEgg";
    [arr addObject:n];
    _contacts = [arr copy];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_contacts count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SupportItem *c = _contacts[indexPath.row];
    NSString *phoneNumber = [@"tel://" stringByAppendingString:c.phoneFiltered];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    SupportItem *c = _contacts[indexPath.row];
    cell.textLabel.text = c.name;
    cell.detailTextLabel.text = c.phone;
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

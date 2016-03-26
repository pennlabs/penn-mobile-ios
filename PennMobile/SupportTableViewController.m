//
//  SupportTableViewController.m
//  PennMobile
//
//  Created by Sacha Best on 1/22/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "SupportTableViewController.h"

@interface SupportTableViewController ()

@property (strong, nonatomic) NSIndexPath *expandedIndexPath;
@property (strong, nonatomic) NSArray *contacts;

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
    
    self.navigationController.navigationBar.tintColor = PENN_YELLOW;
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
    
    SupportItem *pGeneral = [[SupportItem alloc] initWithName:@"Penn Police General" phone:@"(215) 898-7297"];
    pGeneral.descriptionText = @"Call for all non-emergencies";
    SupportItem *pEmergency = [[SupportItem alloc] initWithName:@"Police Emergency/MERT" phone:@"(215) 573-3333"];
    pEmergency.descriptionText = @"Call for all criminal or medical emergencies.";
    SupportItem *pWalk = [[SupportItem alloc] initWithName:@"Penn Walk" phone:@"215-898-WALK (9255)"];
    pWalk.phoneFiltered = @"2158989255";
    pWalk.descriptionText = @"Call this number to have a Public safety officer walk you home between 30th to 43rd Streets and Market Street to Baltimore Avenue.";
    SupportItem *pRide = [[SupportItem alloc] initWithName:@"Penn Ride" phone:@"215-898-RIDE (7433)"];
    pRide.phoneFiltered = @"2158987433";
    pRide.descriptionText = @"Call for Penn Ride services.";
    SupportItem *hLine = [[SupportItem alloc] initWithName:@"Help Line" phone:@"215-898-HELP (4357)"];
    hLine.phoneFiltered = @"2158984357";
    hLine.descriptionText = @"24-hour-a-day phone number for members of the Penn community who are seeking time sensitive help in navigating Penn’s resources for health and wellness.";
    SupportItem *caps = [[SupportItem alloc] initWithName:@"CAPS" phone:@"215-898-7021"];
    caps.descriptionText = @"CAPS main number. Call anytime to reach CAPS";
    SupportItem *special = [[SupportItem alloc] initWithName:@"Special Services" phone:@"215-898-4481"];
    SupportItem *womens = [[SupportItem alloc] initWithName:@"Women's Center" phone:@"215-898-8611"];
    SupportItem *shs = [[SupportItem alloc] initWithName:@"Student Health Services" phone:@"215-746-3535"];
    
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    SupportItem *c = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = c.name;
    
    UIImage *phoneImage = [UIImage imageNamed:@"phone.png"];
    cell.imageView.image = phoneImage;
    CGFloat widthScale = 24.0 / phoneImage.size.width;
    CGFloat heightScale = 24.0 / phoneImage.size.height;
    cell.imageView.transform = CGAffineTransformMakeScale(widthScale, heightScale);
    cell.imageView.tag = indexPath.row;
    
    UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneCalled:)];
    tapped.numberOfTapsRequired = 1;
    cell.imageView.userInteractionEnabled = YES;
    [cell.imageView addGestureRecognizer:tapped];
    
    cell.detailTextLabel.numberOfLines = 0;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

-(void) phoneCalled:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    SupportItem *c = self.contacts[gesture.view.tag];
    NSLog(@"Calling: %@", c.phoneFiltered);
    NSString *phoneNumber = [@"tel://" stringByAppendingString:c.phoneFiltered];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [tableView beginUpdates];
    
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        self.expandedIndexPath = nil;
        [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = @"";
    } else {
        
        [self.tableView cellForRowAtIndexPath:self.expandedIndexPath].detailTextLabel.text = @"";
        
        self.expandedIndexPath = indexPath;
        SupportItem *c = self.contacts[indexPath.row];
        if(c.descriptionText) {
            NSString *descriptionString = [NSString stringWithFormat:@"%@\n%@", c.phone, c.descriptionText];
            [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = descriptionString;
        } else {
            [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = c.phone;
        }
    }
    
    [tableView endUpdates];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        return 100.0;
    }
    return 44.0;
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

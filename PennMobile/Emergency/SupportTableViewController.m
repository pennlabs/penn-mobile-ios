//
//  SupportTableViewController.m
//  PennMobile
//
//  Created by Sacha Best on 1/22/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "SupportTableViewController.h"
#import "PennMobile-Swift.h"
#import "SupportItem.h"

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
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:192.0/255.0f green:57.0/255.0f blue:43.0/255.0f alpha:1.0f];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    [GoogleAnalyticsManager.shared track:@"Contacts"];
    [DatabaseManager.shared track:@"Contacts"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                         style:UIBarButtonItemStylePlain
                                        target:revealController
                                        action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    self.contacts = [SupportItem getContacts];

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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:nil];
    SupportItem *c = [self.contacts objectAtIndex:indexPath.row];
    cell.textLabel.text = c.name;
    
    UIImage *phoneImage = [UIImage imageNamed:@"phone.png"];
    cell.imageView.image = phoneImage;
    CGFloat widthScale = 60 / phoneImage.size.width;
    CGFloat heightScale = 60 / phoneImage.size.height;
    cell.imageView.transform = CGAffineTransformMakeScale(widthScale, heightScale);
    cell.imageView.tag = indexPath.row;
    
    UITapGestureRecognizer *tapped =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(phoneCalled:)];
    tapped.numberOfTapsRequired = 1;
    cell.imageView.userInteractionEnabled = YES;
    [cell.imageView addGestureRecognizer:tapped];
    
    cell.detailTextLabel.numberOfLines = 0;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    [button setUserInteractionEnabled:NO];
//    cell.accessoryView = button;
    
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
    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [tableView beginUpdates];
    
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        self.expandedIndexPath = nil;
        [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = @"";
    } else {
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        [self.tableView cellForRowAtIndexPath:self.expandedIndexPath].detailTextLabel.text = @"";
        
        self.expandedIndexPath = indexPath;
        SupportItem *c = self.contacts[indexPath.row];
        if(c.descriptionText) {
            NSString *descriptionString =
                [NSString stringWithFormat:@"%@\n%@", c.phone, c.descriptionText];
            cell.detailTextLabel.text = descriptionString;
        } else {
            cell.detailTextLabel.text = c.phone;
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

-(void)tableView:(UITableView *)tableView
 willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end

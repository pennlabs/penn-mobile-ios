//
//  MasterTableViewController.m
//  Anypic
//
//  Created by Krishna Bharathala on 9/4/15.
//
//

#import "MasterTableViewController.h"
#import "SWRevealViewController.h"

#import "AppDelegate.h"
#import "MainViewController.h"
#import "LaundryTableViewController.h"
#import "SupportTableViewController.h"
#import "AboutViewController.h"
#import "NewsViewController.h"
#import "DirectoryTableViewController.h"
#import "RegistrarTableViewController.h"

@interface MasterTableViewController () 

typedef NS_ENUM (NSUInteger, MasterTableViewRowType) {
    MasterTableViewRowTypeHome,
    MasterTableViewRowTypeLaundry,
    MastertableViewRowTypeRegistrar,
    MasterTableViewRowTypeDirectory,
    MasterTableViewRowTypeNews,
    MasterTableViewRowTypeAbout,
    MasterTableViewRowTypeSupport,
    MasterTableViewRowTypeCount
};

@property (nonatomic, strong) NSArray *viewControllerArray;
@property (nonatomic, strong) NSArray *iconArray;
@property (nonatomic, retain) UILabel *notificationLabel;

@property (nonatomic) NSInteger currRow;

@end

@implementation MasterTableViewController

@synthesize rearTableView = _rearTableView;

-(void) viewWillAppear:(BOOL)animated {
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:NO];
    [self.revealViewController.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

-(void) viewWillDisappear:(BOOL)animated {
    [self.revealViewController.frontViewController.view setUserInteractionEnabled:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"";
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.bounces = NO;
    
    MainViewController *mainVC = [[MainViewController alloc] init];
    LaundryTableViewController *laundryVC = [[LaundryTableViewController alloc] init];
    RegistrarTableViewController *registrarVC = [[RegistrarTableViewController alloc] init];
    DirectoryTableViewController *directoryVC = [[DirectoryTableViewController alloc] init];
    SupportTableViewController *supportVC = [[SupportTableViewController alloc] init];
    AboutViewController *aboutVC = [[AboutViewController alloc] init];
    NewsViewController *newsVC = [[NewsViewController alloc] init];
    self.viewControllerArray = @[mainVC, laundryVC, registrarVC, directoryVC, newsVC, aboutVC, supportVC];
    
    // self.iconArray = @[@"dining-1.png", @"laundry-2.png", @"news-1.png", @"about-1.png", @"emergency.png"];
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
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
    return MasterTableViewRowTypeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if(indexPath.row < MasterTableViewRowTypeCount) {
        UIViewController *currViewController = [self.viewControllerArray objectAtIndex:indexPath.row];
        cell.textLabel.text = currViewController.title;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // cell.imageView.image = [UIImage imageNamed:[self.iconArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SWRevealViewController *revealController = self.revealViewController;
    
    if (indexPath.row == self.currRow) {
        [revealController setFrontViewPosition:FrontViewPositionLeft animated:YES];
        return;
    }
    
    UIViewController *newFrontController = nil;
    
    if(indexPath.row < MasterTableViewRowTypeCount) {
        newFrontController = [self.viewControllerArray objectAtIndex:indexPath.row];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newFrontController];
        [revealController pushFrontViewController:navigationController animated:YES];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:self.currRow inSection:0];
        [tableView cellForRowAtIndexPath:path].backgroundColor = [UIColor clearColor];
        
        [tableView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor grayColor];
        
        self.currRow = indexPath.row;
    }
}

@end

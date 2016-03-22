//
//  LaundryTableViewController.m
//  PennMobile
//
//  Created by Krishna Bharathala on 10/30/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import "LaundryTableViewController.h"
#import "LaundryMidwayTableViewController.h"
#import "LaundryDetailViewController.h"
#import "LaundryTableViewCell.h"

@interface LaundryTableViewController ()

@property (nonatomic, strong) NSArray *fullLaundryList;
@property (nonatomic, strong) NSMutableDictionary *parsedLaundryList;
@property (nonatomic) BOOL hasLoaded;

@end

@implementation LaundryTableViewController

-(id) init {
    self = [super init];
    if(self) {
        self.title = @"Laundry";
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barTintColor = PENN_BLUE;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
}

-(void) viewDidLoad {
    self.hasLoaded = NO;
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:revealController
                                                                        action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.hasLoaded) {
        [self pull:self];
        self.hasLoaded = YES;
    }
    
    self.tableView.scrollEnabled = NO;
}

- (void) pull:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.tableView.userInteractionEnabled = NO;
    [self performSelectorInBackground:@selector(loadFromAPI) withObject:nil];
}

-(void) loadFromAPI {
    NSString *str=@"http://api.pennlabs.org/laundry/halls";
    NSURL *url =[NSURL URLWithString:str];

    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSError* error;
            self.fullLaundryList = [[NSJSONSerialization JSONObjectWithData:data
                                                                options:kNilOptions
                                                                  error:&error] objectForKey:@"halls"];
            [self parseLaundryList];
        }
        
        [self performSelectorOnMainThread:@selector(hideActivity) withObject:nil waitUntilDone:NO];
        [self.tableView reloadData];
    }];
}

-(void) parseLaundryList {
    self.parsedLaundryList = [[NSMutableDictionary alloc] init];
    for(NSDictionary *info in self.fullLaundryList) {
        NSMutableDictionary *mutInfo = [[NSMutableDictionary alloc] initWithDictionary:info copyItems:YES];
        [mutInfo setValue:[NSString stringWithFormat:@"%lu", [self.fullLaundryList indexOfObject:mutInfo]] forKey:@"index"];
        NSString *header = [[[mutInfo objectForKey:@"name"] componentsSeparatedByString:@"-"] objectAtIndex:0];
        if([self.parsedLaundryList objectForKey:header]) {
            NSMutableArray *tempArray = [self.parsedLaundryList objectForKey:header];
            [tempArray addObject:mutInfo];
            [self.parsedLaundryList setObject:tempArray forKey:header];
        } else {
            NSMutableArray *tempArray = [NSMutableArray arrayWithObject:mutInfo];
            [self.parsedLaundryList setObject:tempArray forKey:header];
        }
    }
}

- (void)hideActivity {
     self.tableView.userInteractionEnabled = YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
 }

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.height / [self.parsedLaundryList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.parsedLaundryList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    
    cell.textLabel.text = [[self.parsedLaundryList allKeys] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *keyArray = [self.parsedLaundryList allKeys];
    NSArray *laundryList = [self.parsedLaundryList objectForKey: [keyArray objectAtIndex:indexPath.row]];
    
    if([laundryList count] == 1) {
        LaundryDetailViewController *laundryDetailVC = [[LaundryDetailViewController alloc] init];
        laundryDetailVC.indexNumber = [[laundryList objectAtIndex:0] objectForKey:@"index"];
        laundryDetailVC.houseName = [[laundryList objectAtIndex:0] objectForKey:@"name"];
        laundryDetailVC.aw = [[[laundryList objectAtIndex:0] objectForKey:@"washers_available"] intValue];
        laundryDetailVC.ad = [[[laundryList objectAtIndex:0] objectForKey:@"dryers_available"] intValue];
        laundryDetailVC.uw = [[[laundryList objectAtIndex:0] objectForKey:@"washers_in_use"] intValue];
        laundryDetailVC.ud = [[[laundryList objectAtIndex:0] objectForKey:@"dryers_in_use"] intValue];
        
        [self.navigationController pushViewController:laundryDetailVC animated:YES];
        
    } else {
        LaundryMidwayTableViewController *laundryDetailTVC = [[LaundryMidwayTableViewController alloc] init];
        laundryDetailTVC.laundryList = laundryList;

        [self.navigationController pushViewController:laundryDetailTVC animated:YES];
    }
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

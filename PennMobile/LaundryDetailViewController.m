//
//  LaundryDetailViewController.m
//  PennMobile
//
//  Created by Krishna Bharathala on 11/13/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import "LaundryDetailViewController.h"
#import "LaundryFloorDetailTableViewCell.h"

@interface LaundryDetailViewController ()

@property (nonatomic, strong) UISegmentedControl *laundrySegment;
@property (nonatomic, strong) NSArray *hallLaundryList;
@property (nonatomic) BOOL hasLoaded;

@property (nonatomic, strong) NSMutableArray *washerList;
@property (nonatomic, strong) NSMutableArray *dryerList;

@end

@implementation LaundryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.hasLoaded = NO;
    self.title = self.houseName;
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    [backButtonItem setTintColor:[UIColor redColor]];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Washers", @"Dryers", nil];
    self.laundrySegment = [[UISegmentedControl alloc] initWithItems:itemArray];
    self.laundrySegment.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [self.laundrySegment addTarget:self action:@selector(changed) forControlEvents: UIControlEventValueChanged];
    self.laundrySegment.selectedSegmentIndex = 0;
    self.laundrySegment.layer.borderWidth =1.5f;
    [self.view addSubview:self.laundrySegment];
    
    self.tableView.frame = CGRectMake(0, 44, self.view.frame.size.width, 0);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.allowsSelection = NO;
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.hasLoaded) {
        [self pull:self];
        self.hasLoaded = YES;
    }
}

- (void) pull:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.tableView.userInteractionEnabled = NO;
    [self performSelectorInBackground:@selector(loadFromAPI) withObject:nil];
}

-(void) loadFromAPI {
    NSString *str= [NSString stringWithFormat:@"http://api.pennlabs.org/laundry/hall/%@", self.indexNumber];
    NSURL *url =[NSURL URLWithString:str];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        } else {
            NSError* error;
            NSDictionary *success = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:kNilOptions
                                                                      error:&error];
            self.hallLaundryList = [success objectForKey:@"machines"];
                                
            self.washerList = [[NSMutableArray alloc] init];
            self.dryerList = [[NSMutableArray alloc] init];
            
            for(NSDictionary *machine in self.hallLaundryList) {
                if ([[machine objectForKey:@"machine_type"] rangeOfString:@"washer"
                                                                  options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [self.washerList addObject:machine];
                } else {
                    [self.dryerList addObject:machine];
                }
            }
        }
        
        [self performSelectorOnMainThread:@selector(hideActivity) withObject:nil waitUntilDone:NO];
        [self.tableView reloadData];
    }];
}

- (void)hideActivity {
    self.tableView.userInteractionEnabled = YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void) changed {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        return 44;
    }if(indexPath.row == 1) {
        return 50*3;
    } else {
        return 50;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.laundrySegment.selectedSegmentIndex == 0) {
        return [self.washerList count]+2;
    } else {
        return [self.dryerList count]+2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    if(indexPath.row == 0) {
        cell.textLabel.text = @"";
        cell.backgroundColor = [UIColor whiteColor];
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"";
        cell.imageView.image = [UIImage imageNamed:@"washer_icon.png"];
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        if(self.laundrySegment.selectedSegmentIndex == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"Washer %lu", indexPath.row-1];
            if([[[self.washerList objectAtIndex:indexPath.row-2] objectForKey:@"available"] boolValue]) {
                cell.detailTextLabel.text = @"Available";
                cell.detailTextLabel.textColor = [UIColor greenColor];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Busy - %@", [[self.dryerList objectAtIndex:indexPath.row-2] objectForKey:@"time_left"]];
                UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
                cell.accessoryView = switchview;
                cell.detailTextLabel.textColor = [UIColor redColor];
            }
        } else {
            cell.textLabel.text = [NSString stringWithFormat:@"Dryer %lu", indexPath.row-1];
            if([[[self.dryerList objectAtIndex:indexPath.row-2] objectForKey:@"available"] boolValue]) {
                cell.detailTextLabel.text = @"Available";
                cell.detailTextLabel.textColor = [UIColor greenColor];
            } else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"Busy - %@", [[self.dryerList objectAtIndex:indexPath.row-2] objectForKey:@"time_left"]];
                UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
                cell.accessoryView = switchview;
                cell.detailTextLabel.textColor = [UIColor redColor];
            }
        }
    }
    
    return cell;
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

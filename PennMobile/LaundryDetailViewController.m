//
//  LaundryDetailViewController.m
//  PennMobile
//
//  Created by Krishna Bharathala on 11/13/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import "LaundryDetailViewController.h"

@interface LaundryDetailViewController ()

@property (nonatomic, strong) UISegmentedControl *laundrySegment;
@property (nonatomic, strong) NSDictionary *hallLaundryList;
@property (nonatomic) BOOL hasLoaded;

@end

@implementation LaundryDetailViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.hasLoaded) {
        [self pull:self];
        self.hasLoaded = YES;
    }
}

- (void) pull:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //self.tableView.userInteractionEnabled = NO;
    NSLog(@"%@", self.indexNumber);
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
            self.hallLaundryList = [[NSJSONSerialization JSONObjectWithData:data
                                                                    options:kNilOptions
                                                                      error:&error] objectForKey:@"machines"];
            NSLog(@"%@", self.hallLaundryList);
        }
        
        [self performSelectorOnMainThread:@selector(hideActivity) withObject:nil waitUntilDone:NO];
        [self reloadInputViews];
    }];
}

- (void)hideActivity {
    //self.tableView.userInteractionEnabled = YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.hasLoaded = NO;

    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    [backButtonItem setTintColor:[UIColor redColor]];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Washers", @"Dryers", nil];
    self.laundrySegment = [[UISegmentedControl alloc] initWithItems:itemArray];
    self.laundrySegment.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    [self.laundrySegment addTarget:self action:@selector(changed) forControlEvents: UIControlEventValueChanged];
    self.laundrySegment.selectedSegmentIndex = 0;
    self.laundrySegment.layer.borderWidth =1.5f;
    [self.view addSubview:self.laundrySegment];
}

-(void) changed {
    NSLog(@"hi");
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

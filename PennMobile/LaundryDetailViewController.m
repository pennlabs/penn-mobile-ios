//
//  LaundryDetailViewController.m
//  PennMobile
//
//  Created by Krishna Bharathala on 11/13/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import "LaundryDetailViewController.h"

@interface LaundryDetailViewController ()

@end

@implementation LaundryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSLog(@"%@", self.laundryInfo);
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    [backButtonItem setTintColor:[UIColor redColor]];
    
    UILabel *washerLabel = [[UILabel alloc] init];
    washerLabel.text = [NSString stringWithFormat:@"Washers Available: %@", [self.laundryInfo objectForKey:@"washers_available"]];
    [washerLabel sizeToFit];
    [washerLabel setTextColor: [UIColor blackColor]];
    [washerLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:washerLabel];
    
    UILabel *dryerLabel = [[UILabel alloc] init];
    dryerLabel.text = [NSString stringWithFormat:@"Dryers Available: %@", [self.laundryInfo objectForKey:@"dryers_available"]];
    [dryerLabel sizeToFit];
    [dryerLabel setTextColor: [UIColor blackColor]];
    [dryerLabel setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 100)];
    [self.view addSubview:dryerLabel];
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

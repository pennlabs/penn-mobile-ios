//
//  TabViewController.m
//  PennMobile
//
//  Created by Sacha Best on 11/13/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "TabViewController.h"

@interface TabViewController ()

@end

@implementation TabViewController

- (void)viewWillLayoutSubviews {
    [TabViewController configureTabColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
+ (void)configureTabColor {
    //[[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:10/255.0 green:37/255.0 blue:69/255.0 alpha:1]];
   // [[UITabBar appearance] setAlpha:0.25];
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

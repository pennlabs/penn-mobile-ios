//
//  PennNavController.m
//  PennMobile
//
//  Created by Sacha Best on 9/9/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "PennNavController.h"

@interface PennNavController ()

@end

@implementation PennNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIView *blackView = [[UIView alloc] initWithFrame:self.view.frame];
    [blackView setBackgroundColor:[UIColor blackColor]];
    [blackView setOpaque:NO];
    [blackView setAlpha:0.2f];
    [self.view addSubview:blackView];
    _grayedOut = YES;
}


@end

//
//  FoodDetailViewController.m
//  PennMobile
//
//  Created by Sacha Best on 1/20/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "FoodDetailViewController.h"

@interface FoodDetailViewController ()

@end

@implementation FoodDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titleLabel.text = [_titleString capitalizedString];
    _sub.text = _subString;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(drop:)];
    [self.view addGestureRecognizer:tap];
}
-(IBAction)drop:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        // insert deselect code here
        //[_tableView deselectRowAtIndexPath:_indexPath animated:YES];
    }];
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

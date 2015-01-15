//
//  TransitViewController.m
//  PennMobile
//
//  Created by Sacha Best on 9/30/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "TransitViewController.h"

@interface TransitViewController ()

@end

@implementation TransitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.pennrides.com/map?showHeader=0&route=229,230&silent_disable_timeout=1"]];
    [_webView loadRequest:req];
    _webView.scalesPageToFit = NO;
    _webView.delegate = self;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (!webView.loading) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
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

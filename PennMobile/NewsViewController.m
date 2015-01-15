//
//  NewsViewController.m
//  PennMobile
//
//  Created by Sacha Best on 11/13/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController ()

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://thedp.com"]];
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

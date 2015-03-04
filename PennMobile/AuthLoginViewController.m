//
//  AuthLoginViewController.m
//  PennMobile
//
//  Created by Sacha Best on 3/3/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "AuthLoginViewController.h"

@interface AuthLoginViewController ()

@end

@implementation AuthLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:AUTH_URL]];
    [_webView loadRequest:req];
    _webView.scalesPageToFit = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSURL *u = [webView.request mainDocumentURL];
    NSLog(@"Loaded url: %@", u);
    if ([u.host isEqualToString:@"api.pennlabs.org"]) {
        // store the auth token
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        NSString *query = u.query;
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        for (NSString *param in [query componentsSeparatedByString:@"&"]) {
            NSArray *elts = [param componentsSeparatedByString:@"="];
            if ([elts count] < 2) continue;
            [params setObject:[elts objectAtIndex:1] forKey:[elts objectAtIndex:0]];
        }
        [def setObject:params[@"token"] forKey:@"token"];
        [def setObject:params[@"expiry"] forKey:@"expiry"];
    }
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

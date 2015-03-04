//
//  AuthLoginViewController.h
//  PennMobile
//
//  Created by Sacha Best on 3/3/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface AuthLoginViewController : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

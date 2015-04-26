//
//  NewsViewController.h
//  PennMobile
//
//  Created by Sacha Best on 11/13/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideOutMenuViewController.h"

@interface NewsViewController : UIViewController <UIWebViewDelegate> {
    UITapGestureRecognizer *cancelTouches;
}

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *newsSwitcher;
@property NSString *url;
@end

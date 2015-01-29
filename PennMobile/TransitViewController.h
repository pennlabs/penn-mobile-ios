//
//  TransitViewController.h
//  PennMobile
//
//  Created by Sacha Best on 9/30/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideOutMenuViewController.h"

@interface TransitViewController : UIViewController <UIWebViewDelegate> {
    UITapGestureRecognizer *cancelTouches;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

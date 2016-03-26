//
//  NewsViewController.h
//  PennMobile
//
//  Created by Sacha Best on 11/13/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideOutMenuViewController.h"

@interface NewsViewController : UIViewController <UIWebViewDelegate, UIToolbarDelegate> {
    UITapGestureRecognizer *cancelTouches;
}

@property NSString *url;

@end

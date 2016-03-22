//
//  AboutViewController.h
//  PennMobile
//
//  Created by Sacha Best on 10/14/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SlideOutMenuViewController.h"

@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    UITapGestureRecognizer *cancelTouches;
}

@end

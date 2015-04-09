//
//  SlideOutMenuViewController.h
//  PennMobile
//
//  Created by Sacha Best on 12/17/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PennNavController.h"
#import "NewsViewController.h"

@interface SlideOutMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate> {
    NSString *currentView;
    NSIndexPath *start;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *labsImage;
@property bool menuOut;

@property NSArray *views;

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue;
- (IBAction)returnToView:(id)sender;
+ (SlideOutMenuViewController *)instance;

@end

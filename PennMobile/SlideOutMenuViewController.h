//
//  SlideOutMenuViewController.h
//  PennMobile
//
//  Created by Sacha Best on 12/17/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideOutMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSString *currentView;
    NSIndexPath *start;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *labsImage;
@property NSArray *views;

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue;
@end

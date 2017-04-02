//
//  FoodDetailViewController.h
//  PennMobile
//
//  Created by Sacha Best on 1/20/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sub;
@property NSString *titleString;
@property NSString *subString;
@property NSIndexPath *indexPath;
@end

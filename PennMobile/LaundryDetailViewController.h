//
//  LaundryDetailViewController.h
//  PennMobile
//
//  Created by Krishna Bharathala on 11/13/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LAUNDRY_PATH @"laundry/hall/"

@interface LaundryDetailViewController : UITableViewController

@property (nonatomic, strong) NSNumber *indexNumber;
@property (nonatomic, strong) NSString *houseName;

@property (nonatomic) int aw;
@property (nonatomic) int uw;
@property (nonatomic) int ad;
@property (nonatomic) int ud;


@end

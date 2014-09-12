//
//  DiningViewController.h
//  PennMobile
//
//  Created by Sacha Best on 9/9/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiningTableViewCell.h"

#define kTitleKey @"title"
#define kAddressKey @"address"
#define kSampleVenueJSON @"venue_sample.txt"

@interface DiningViewController : UITableViewController {
    NSDictionary *innerJSON;
    NSString *menuMessage;
    NSString *currentVenue;
}

@property NSMutableDictionary *venues;


- (void)loadFromAPI;
- (void)loadFromAPIwithTarget:(id)target selector:(SEL)selector;
- (NSDictionary *)getMealsForVenue:(NSString *)venue forDate:(NSString *)date;

@end

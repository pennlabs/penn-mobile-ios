//
//  DiningViewController.h
//  PennMobile
//
//  Created by Sacha Best on 9/9/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DiningTableViewCell.h"
#import "MenuViewController.h"

#define kTitleKey @"title"
#define kAddressKey @"address"
#define kTableDayPart @"tblDayPart"
#define kStation @"tblStation"
#define kSampleVenueJSON @"venue_sample.txt"

@interface DiningViewController : UITableViewController {
    NSString *menuMessage;
    NSString *currentVenue;
    NSArray *dataForNextView;
}

typedef NS_ENUM(NSInteger, Meal) {
    Breakfast = 0,
    Lunch = 1,
    Dinner = 2
};

@property NSMutableDictionary *venues;

- (void)loadFromAPI;
- (void)loadFromAPIwithTarget:(id)target selector:(SEL)selector;
- (NSArray *)getMealsForVenue:(NSString *)venue forDate:(NSString *)date atMeal:(Meal)meal;

@end

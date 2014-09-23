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
    CGRect titleSuperviewBounds;
    UIEdgeInsets titleViewMargins;
}

typedef NS_ENUM(NSInteger, Meal) {
    Breakfast = 0,
    Lunch = 1,
    Dinner = 2
};

@property NSMutableDictionary *venues;

/**
 * The data stored in these two arrays adds to overall space required but gives a performance increase on accessing.
 **/

@property NSMutableSet *days;
@property NSMutableSet *mealTimes;

- (void)loadFromAPI;
- (void)loadFromAPIwithTarget:(id)target selector:(SEL)selector;
- (NSArray *)getMealsForVenue:(NSString *)venue forDate:(NSString *)date atMeal:(Meal)meal;
- (NSArray *)getDates;
- (NSArray *)getMealTimes;
@end

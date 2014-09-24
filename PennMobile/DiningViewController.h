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
    NSDateFormatter *venueJSONFormatter;
    NSDateFormatter *hoursJSONFormatter;
}

typedef NS_ENUM(NSInteger, Meal) {
    Breakfast = 0,
    Lunch,
    Dinner,
    Brunch
};

/**
 * FORMAT:
 * barf
 **/
@property NSMutableDictionary *venues;

/**
 * FORMAT: 
 * "name" -> NSDictionary -
 * "date" -> NSDate
 * "meals" -> NSArray -
 * "meal" -> NSDictionary -
 * "title" -> NSString
 * "open" -> NSDate
 * "close" -> NSDate
 **/
@property NSMutableArray *mealTimes;

/**
 * The data stored in these two arrays adds to overall space required but gives a performance increase on accessing.
 **/

@property NSMutableSet *days;

- (void)loadFromAPI;
- (void)loadFromAPIwithTarget:(id)target selector:(SEL)selector;

// API loading helpers

- (void)loadVenues;

// Data Accessors

- (NSArray *)getMealsForVenue:(NSString *)venue forDate:(NSString *)date atMeal:(Meal)meal;
- (NSArray *)getDates;
- (NSArray *)getMealTimes;

// Global helpers

- (bool)matchVenue:(NSString *)one withOther:(NSString *)two;
- (Meal)stringTimeToEnum:(NSString *)mealTime;
- (NSString *)enumToStringTime:(Meal)mealTime;
// This can return null - watch out
- (Meal)isOpen:(NSString *)venue;

@end

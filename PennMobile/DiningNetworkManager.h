//
//  DiningNetworkManager.h
//  PennMobile
//
//  Created by Josh Doman on 3/31/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meal.h"

#define kTitleKey @"title"
#define kAddressKey @"address"
#define kTableDayPart @"tblDayPart"
#define kStation @"tblStation"
#define kSampleVenueJSON @"venue_sample.txt"

#define SERVER_PATH @"dining/venues"
#define MEAL_PATH @"dining/weekly_menu/"

@interface PCRAggregator : NSObject

+ (NSArray *) getMeals: (NSDate *)date venue:(NSString *)venueName;

@end

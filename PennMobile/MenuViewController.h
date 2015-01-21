//
//  MenuViewController.h
//  PennMobile
//
//  Created by Sacha Best on 9/11/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodItemTableViewCell.h"
#import "DiningViewController.h"
#import "Meal.h"
#import "FoodDetailViewController.h"

@class DiningViewController;

@interface MenuViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    UIPickerView *mealPicker;
    UIView *pickerTopBar;
    NSArray *dates;
    NSDateFormatter *weekday;
}

/**
 * Food is an array of stations - each station is an NSDictionary with an entry in 
 * @"station" with the name of the station and then there is another NSDictionary
 * with the food items in it.
 * This implementation is somewhat precarious but gets the job done for now. 
 * MOVED: now pulled from previous view using source.*
 **/

@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *dateButton;
@property (strong, nonatomic) UITextField *dummyText;
@property DiningViewController *source;

- (void)populateSectionTypes;
- (void)cancelChooser:(id)sender;
- (void)confirmChooser:(id)sender;
- (IBAction)timeButtonClicked:(id)sender;
- (IBAction)dateButtonClicked:(id)sender;
@end

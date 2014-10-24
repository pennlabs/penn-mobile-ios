//
//  MenuViewController.m
//  PennMobile
//
//  Created by Sacha Best on 9/11/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 60.0f;
    /*
    _dummyText = [[UITextField alloc] init];
    picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, self.view.window.bounds.size.width, self.view.window.bounds.size.height / 2.5)];
    picker.datePickerMode = UIDatePickerModeDate;
    picker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    picker.minimumDate = _dates[0];
    picker.maximumDate = _dates[_dates.count - 1];
    pickerTopBar = [[UIToolbar alloc] init];
    pickerTopBar.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(confirmChooser:)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelChooser:)];
    [pickerTopBar setItems:@[cancel, confirm]];
    
    mealPicker = [[UIPickerView alloc] init];
    mealPicker.dataSource = self;
    mealPicker.delegate = self;
    [_dummyText setInputView:picker];
    _dummyText.inputAccessoryView = pickerTopBar;
    [self.view addSubview:_dummyText];
     */
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Picker View Stuff

- (void)confirmChooser:(id)sender {
    [_dummyText resignFirstResponder];
    // Now switch date
    _food = [_source getMealsForVenue:_currentVenue forDate:_currentDate atMeal:_currentMeal];
}
- (void)cancelChooser:(id)sender {
    [_dummyText resignFirstResponder];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _food.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return ((NSArray *)_food[section][@"food"]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _food[section][@"station"];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FoodItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.text = _food[indexPath.section][@"food"][indexPath.row][@"title"];
    cell.descriptionLabel.text = _food[indexPath.section][@"food"][indexPath.row][@"description"];
    // Configure the cell...
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - Button Controls

// This needs to show a picker that allows the user to select which meal time they want to see
- (IBAction)timeButtonClicked:(id)sender {
    
}

// This needs to show a picker that allows the user to choose the date for which they want to see
- (IBAction)dateButtonClicked:(id)sender {
    [_dummyText becomeFirstResponder];

}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

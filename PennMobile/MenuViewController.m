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
    
    NSLog(@"I AM HERE I THINK");
    
    [super viewDidLoad];
    
    dates = [_source getDates];
    _dummyText = [[UITextField alloc] init];
    mealPicker = [[UIPickerView alloc] init];
    mealPicker.delegate = self;
    mealPicker.dataSource = self;
    
    pickerTopBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
    pickerTopBar.backgroundColor = PENN_BLUE;
    
    self.navigationItem.title = @"Hours";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:self action:@selector(cancelChooser:)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStyleBordered target:self action:@selector(confirmChooser:)];
    confirm.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelChooser:)];
    cancel.tintColor = [UIColor whiteColor];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithObjects:confirm, cancel, nil];
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:pickerTopBar.frame];
    bar.barStyle = UIBarStyleBlack;
    bar.translucent = NO;
    bar.barTintColor = PENN_BLUE;
    [bar setItems:buttons];
    [pickerTopBar addSubview:bar];
    
    weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat:@"EEEE"];
    
    [_dummyText setInputView:mealPicker];
    _dummyText.inputAccessoryView = pickerTopBar;
    [self.view addSubview:_dummyText];
    timeString = [_source getTimeStringForVenue:_source.selectedVenue onDate:[NSDate date]];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
}
- (void) viewWillAppear:(BOOL)animated {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Picker View Stuff

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return dates.count;
        case 1:
            return self.source.mealsServed.count;
        default:
            return 0;
    }
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [weekday stringFromDate:dates[row]];
        case 1:
            return _source.mealsServed[row];
        default:
            return @"";
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    if (component == 0) { // weekday picker
        // update the meals picker to show only valid meals for the selected day
        NSInteger mealRow = [mealPicker selectedRowInComponent:1];
        _source.dataForNextView = [_source switchMeal:dates[row] meal:[_source stringTimeToEnum:_source.mealsServed[mealRow] ]];
        [pickerView reloadComponent:1];
    }
}

- (void)confirmChooser:(id)sender {
    NSInteger dateRow = [mealPicker selectedRowInComponent:0];
    NSInteger mealRow = [mealPicker selectedRowInComponent:1];
    if (dateRow < 0 || mealRow < 0 || dateRow >= dates.count || mealRow >= _source.mealsServed.count) {
        UIAlertView *invalid = [[UIAlertView alloc] initWithTitle:@"Invalid Choice" message:@"That was not a valid selection. Please make sure you choose the correct meal and date." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [invalid show];
        return;
    }
    [_dummyText resignFirstResponder];
    // Now switch date
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.tableView.userInteractionEnabled = NO;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // _currentVeneu is null here
        // don't think its ever set
        timeString = [_source getTimeStringForVenue:_source.selectedVenue onDate:dates[dateRow]];
        _source.dataForNextView = [_source switchMeal:dates[dateRow] meal:[_source stringTimeToEnum:_source.mealsServed[mealRow] ]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self tableView] reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            self.tableView.userInteractionEnabled = YES;
        });
    });
}
- (void)cancelChooser:(id)sender {
    [_dummyText resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _source.dataForNextView.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return ((NSArray *)_source.dataForNextView[section][@"food"]).count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _source.dataForNextView[section][@"station"];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FoodItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.titleLabel.text = _source.dataForNextView[indexPath.section][@"food"][indexPath.row][@"title"];
    cell.descriptionLabel.text = _source.dataForNextView[indexPath.section][@"food"][indexPath.row][@"description"];
    // Configure the cell...
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selected = indexPath;
}

#pragma mark - Button Controls

// This needs to show a picker that allows the user to select which meal time they want to see
- (IBAction)timeButtonClicked:(id)sender {
    
}

// This needs to show a picker that allows the user to choose the date for which they want to see
- (IBAction)dateButtonClicked:(id)sender {
    [_dummyText becomeFirstResponder];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"Detail"]) {
        FoodDetailViewController *food = segue.destinationViewController;
        FoodItemTableViewCell *item = sender;
        if (item.descriptionLabel.text) {
            food.subString = item.descriptionLabel.text;
        }
        food.titleString = item.titleLabel.text;
        food.indexPath = selected;
    } else if ([segue.identifier isEqualToString:@"Times"]) {
        FoodDetailViewController *food = segue.destinationViewController;
        food.titleString = _source.selectedVenue;
        food.subString = timeString;
    }
    // need to handle unwind segue from detail view to un-highlight the cell
}


@end

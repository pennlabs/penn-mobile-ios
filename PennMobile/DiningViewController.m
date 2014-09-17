//
//  DiningViewController.m
//  PennMobile
//
//  Created by Sacha Best on 9/9/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "DiningViewController.h"

@interface DiningViewController ()

@end

@implementation DiningViewController

bool usingTempData;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = logo;
    self.tableView.rowHeight = 100.0f;
    _venues = [[NSMutableDictionary alloc] initWithCapacity:4];
    _days = [[NSMutableSet alloc] initWithCapacity:5];
    _mealTimes = [[NSMutableSet alloc] initWithCapacity:4];
    [self loadFromAPI];
    if (!_venues) {
        usingTempData = true;
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of dining halls available
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hall" forIndexPath:indexPath];
    if (!cell) {
        cell = [[DiningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hall"];

    }
    switch (indexPath.row) {
        case 0:
            cell.venueLabel.text = @"Hill House";
            break;
        case 1:
            cell.venueLabel.text = @"Kings Court English House";
            break;
        case 2:
            cell.venueLabel.text = @"1920 Commons";
            break;
        case 3:
            cell.venueLabel.text = @"McCleland Hall";
            break;
        default:
            break;
    }
    // Configure the cell...
    if (usingTempData) {
        cell.venueLabel.text = @"University of Pennsylvania Hill House";
        cell.addressLabel.text = @"1000 Sacha St, Best, CA 90210";
    } else {
        //cell.venueLabel.text = _venues[indexPath.row])[kTitleKey];
        //cell.addressLabel.text = _venues[indexPath.row][kAddressKey];
    }
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *venueName = ((DiningTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).venueLabel.text;
    venueName = [@"University of Pennsylvania " stringByAppendingString:venueName];
    dataForNextView = [self getMealsForVenue:venueName forDate:@"9/8/2014" atMeal:Lunch];
    [self performSegueWithIdentifier:@"cellClick" sender:[tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"cellClick"]) {
        ((MenuViewController *)segue.destinationViewController).food = dataForNextView;
        ((MenuViewController *)segue.destinationViewController).dates = [self getDates];

    }
}


#pragma mark - API-loading

- (void)loadFromAPI {
    [self loadFromAPIwithTarget:nil selector:nil];
}

// TODO : instert API loading code here
// Clarra - this is backgrounded with a callback. Any code you put here will execute
// asynchronously and then call the function listed in target and selector

- (void)loadFromAPIwithTarget:(id)target selector:(SEL)selector {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // TEMP - this code reads from an included sample JSON file
        NSString *path = [[NSBundle mainBundle] pathForResource:@"venue_sample" ofType:@"txt"];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:path];
        NSError *error = [NSError alloc];
        NSDictionary *raw = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        NSArray *currentDay;
        NSMutableDictionary *days = [[NSMutableDictionary alloc] init];
        for (int num = 0; num < ((NSArray *) raw[@"Document"][@"tblMenu"]).count; num++) {
            currentDay = [raw[@"Document"][@"tblMenu"][num] objectForKey:kTableDayPart];
            // Data validation - this works ;;;;;
            // NSLog(@"%@", currentDay[0][@"txtDayPartDescription"]);
            NSString *date = raw[@"Document"][@"tblMenu"][num][@"menudate"];
            [days setObject: currentDay forKey:date];
            [_days addObject:date];
        }
        menuMessage = raw[@"Document"][@"tblMessages"][@"txtNoMenuMessage"];
        currentVenue = raw[@"Document"][@"location"];
        [_venues setObject:days forKey:currentVenue];
        if (error.code != 0) {
            [NSException raise:@"JSON parse error" format:@"%@", error];
        }
        if (target && selector) {
            // Go back to main thread to perform callback
            [target performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
        }
    });
}
- (NSArray *)getMealsForVenue:(NSString *)venue forDate:(NSString *)date atMeal:(Meal)meal {
    NSMutableArray *toReturn = [[NSMutableArray alloc] init];
    NSDictionary *venueContents = _venues[venue];
    NSArray *mealOptions;
    for (NSString *day in [venueContents allKeys]) {
        if ([day isEqualToString:date]) {
            mealOptions = venueContents[day][meal][kStation];
            for (int station = 0; station < mealOptions.count; station++) {
                NSMutableDictionary *currentStation = [[NSMutableDictionary alloc] initWithCapacity:3];
                id stationItems = mealOptions[station][@"tblItem"];
                [currentStation setObject:mealOptions[station][@"txtStationDescription"] forKey:@"station"];
                NSMutableArray *food = [[NSMutableArray alloc] init];
                // This is absolutely ridiculous
                // If the station only has 1 item, they don't include it in an array in JSON
                // so the two cases (1 item vs 1+) have to be handled individually
                if ([stationItems isKindOfClass:[NSArray class]]) {
                    for (int item = 0; item < ((NSArray *)stationItems).count; item++) {
                        NSString *description = stationItems[item][@"txtDescription"];
                        NSString *title = stationItems[item][@"txtTitle"];
                        NSDictionary *foodItem = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title", description, @"description", nil];
                        [food addObject:foodItem];
                    }
                } else {
                    NSString *description = stationItems[@"txtDescription"];
                    NSString *title = stationItems[@"txtTitle"];
                    NSDictionary *foodItem = [[NSDictionary alloc] initWithObjectsAndKeys:title, @"title", description, @"description", nil];
                    [food addObject:foodItem];
                }
                [currentStation setObject:food forKey:@"food"];
                [toReturn addObject:currentStation];
            }
        }
    }
    return toReturn;
}

#pragma mark - Data Acessors

- (NSArray *)getDates {
    return [_days allObjects];
}
@end

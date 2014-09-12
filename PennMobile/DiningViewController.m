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
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hall" forIndexPath:indexPath];
    if (!cell) {
        cell = [[DiningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"hall"];

    }
    // Configure the cell...
    if (usingTempData) {
        cell.venueLabel.text = @"Hill House";
        cell.addressLabel.text = @"1000 Sacha St, Best, CA 90210";
    } else {
        cell.venueLabel.text = _venues[indexPath.row][kTitleKey];
        cell.addressLabel.text = _venues[indexPath.row][kAddressKey];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
        innerJSON = raw[@"Document"][@"tblMenu"];
        menuMessage = raw[@"Document"][@"tblMessages"][@"txtNoMenuMessage"];
        currentVenue = @"Hill House";
        [_venues setObject:innerJSON forKey:currentVenue];
        if (error.code != 0) {
            [NSException raise:@"JSON parse error" format:@"%@", error];
        }
        if (target && selector) {
            // Go back to main thread to perform callback
            [target performSelectorOnMainThread:selector withObject:nil waitUntilDone:NO];
        }
    });
}
- (NSDictionary *)getMealsForVenue:(NSString *)venue forDate:(NSString *)date {
    NSMutableDictionary *toReturn = [[NSMutableDictionary alloc] init];
    NSDictionary *venueContents = _venues[venue];
    for (NSString *key in venueContents) {
        if ([venueContents[key][@"menudate"] isEqualToString:date]) {
            NSDictionary *currentDay = venueContents[key][@"tblDayPart"];
        }
    }
}
@end

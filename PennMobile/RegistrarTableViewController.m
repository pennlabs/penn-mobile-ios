//
//  RegistrarTableViewController.m
//  PennMobile
//
//  Created by Sacha Best on 9/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "RegistrarTableViewController.h"

@interface RegistrarTableViewController ()

@end

@implementation RegistrarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // to dismiss the keyboard when the user taps on the table
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard:(id)sender {
    [_searchBar resignFirstResponder];
}
#pragma mark - API

-(NSSet *)searchForName:(NSString *)name {
    // This is a set because multiple terms qre queried and we don't want duplicate results
    NSMutableSet *results = [[NSMutableSet alloc] init];
    if ([name containsString:@" "]) {
        NSArray *split = [name componentsSeparatedByString:@" "];
        for (NSString *queryTerm in split) {
            [results addObjectsFromArray:[self queryAPI:queryTerm]];
        }
    }
    return results;
}

-(NSArray *)queryAPI:(NSString *)term {
    NSData *result = [NSData dataWithContentsOfURL:[NSURL URLWithString:[REGISTRAR_PATH stringByAppendingString:term] relativeToURL:[NSURL URLWithString:SERVER_ROOT]]];
    NSError *error;
    NSArray *returned = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
    if (error.code != 0) {
        [NSException raise:@"JSON parse error" format:@"%@", error];
    }
    return returned;
}

-(void)importData:(NSSet *)raw {
    NSMutableSet *tempSet = [[NSMutableSet alloc] initWithCapacity:raw.count];
    for (NSDictionary *courseData in raw) {
        Course *new = [[Course alloc] init];
        new.identifier = courseData[@"_id"];
        new.dept = courseData[@"dept"];
        new.title = courseData[@"title"];
        new.courseNum = courseData[@"courseNumber"];
        new.credits = courseData[@"credits"];
        new.sectionNum = courseData[@"sectionNumber"];
        new.type = courseData[@"type"];
        new.times = courseData[@"times"];
        new.building = courseData[@"building"];
        new.roomBum = courseData[@"roomNumber"];
        new.prof = courseData[@"prof"];
        [tempSet addObject:new];
    }
    _courses = [tempSet allObjects];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _courses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RegistrarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"class" forIndexPath:indexPath];
    Course *inQuestion = _courses[indexPath.row];
    cell.textLabel.text = inQuestion.title;
    cell.detailTextLabel.text = inQuestion.prof;
    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self queryAPI:searchBar.text];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self queryAPI:searchText];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

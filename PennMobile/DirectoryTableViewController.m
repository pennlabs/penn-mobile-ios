//
//  DirectoryTableViewController.m
//  PennMobile
//
//  Created by Sacha Best on 9/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "DirectoryTableViewController.h"

@interface DirectoryTableViewController ()

@end

@implementation DirectoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // to dismiss the keyboard when the user taps on the table
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tap];
    _searchBar.delegate = self;
    tempSet = [[NSMutableOrderedSet alloc] initWithCapacity:20];
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview: activityIndicator];
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
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", SERVER_ROOT, DIRECTORY_PATH, term]];
    NSData *result = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSDictionary *returned = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        [NSException raise:@"JSON parse error" format:@"%@", error];
    }
    return returned[@"result_data"];
}

-(void)importData:(NSArray *)raw {
    for (NSDictionary *personData in raw) {
        Person *new = [[Person alloc] init];
        new.name = personData[@"list_name"];
        new.phone = personData[@"list_phone"];
        new.email = personData[@"list_email"];
        new.identifier = personData[@"person_id"];
        new.organization = personData[@"list_organization"];
        //new.affiliation = personData[@"list_affiliation"];
        [tempSet addObject:new];
    }
    _people = [tempSet sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *courseNum1 = ((Person *)obj1).name;
        NSString *courseNum2 = ((Person *)obj1).name;
        return [courseNum1 compare:courseNum2];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _people.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"person" forIndexPath:indexPath];
    
    [cell configure:_people[indexPath.row]];
    
    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length <= 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Search" message:@"Please search by at least 3 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        [_searchBar resignFirstResponder];
        [activityIndicator startAnimating];
        [self performSelectorInBackground:@selector(queryHandler:) withObject:searchBar.text];
    }
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 2) {
        [self performSelectorInBackground:@selector(queryHandler:) withObject:searchBar.text];
    }
}
- (void)queryHandler:(NSString *)search {
    [self importData:[self queryAPI:search]];
    [self performSelectorOnMainThread:@selector(reloadView) withObject:nil waitUntilDone:NO];
}
- (void)reloadView {
    [self.tableView reloadData];
    [activityIndicator stopAnimating];
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

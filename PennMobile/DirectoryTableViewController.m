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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"person" forIndexPath:indexPath];
    
    [cell configure:super.objects[indexPath.row]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


-(void)importData:(NSArray *)raw {
    if (!raw)
        return;
    for (NSDictionary *personData in raw) {
        Person *new = [[Person alloc] init];
        new.name = [personData[@"list_name"] capitalizedString];
        new.phone = personData[@"list_phone"];
        new.email = personData[@"list_email"];
        new.identifier = personData[@"person_id"];
        new.organization = [personData[@"list_organization"] capitalizedString];
        //new.affiliation = personData[@"list_affiliation"];
        [tempSet addObject:new];
    }
    super.objects = [tempSet sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *courseNum1 = ((Person *)obj1).name;
        NSString *courseNum2 = ((Person *)obj1).name;
        return [courseNum1 compare:courseNum2];
    }];
    if (tempSet && tempSet.count > 0)
        [tempSet removeAllObjects];
}

- (NSDictionary *)requetPersonDetails:(NSString *)name {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", SERVER_ROOT, DETAIL_PATH, name]];
    NSData *result = [NSData dataWithContentsOfURL:url];
    NSError *error;
    NSDictionary *returned = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        [NSException raise:@"JSON parse error" format:@"%@", error];
    }
    return returned;
}
- (NSObject *)parseData:(NSDictionary *)data {
    Person *new = [[Person alloc] init];
    new.name = data[@"detail_name"];
    new.title = data[@"title"];
    new.organization = data[@"list_organization_pub"];
    new.affiliation = data[@"list_affiliation"];
    return new;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //forSegue = _people[indexPath.row];
    //[self performSegueWithIdentifier:@"detail" sender:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length <= 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Search" message:@"Please search by at least 3 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        [super.searchBar resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [super performSelectorInBackground:@selector(queryHandler:) withObject:searchBar.text];
    }
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 2) {
        [super performSelectorInBackground:@selector(queryHandler:) withObject:searchText];
    }
    if(![super.searchBar isFirstResponder]) {
        [self searchBarCancelButtonClicked:super.searchBar];
    }
}

-(NSArray *)queryAPI:(NSString *)term {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", SERVER_ROOT, DIRECTORY_PATH, term]];
    NSData *result = [NSData dataWithContentsOfURL:url];
    if (![super confirmConnection:result]) {
        return nil;
    }
    NSError *error;
    if (!result) {
        CLS_LOG(@"Data parameter was nil for query..returning null");
        return nil;
    }
    NSDictionary *returned = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        [NSException raise:@"JSON parse error" format:@"%@", error];
    }
    return returned[@"result_data"];
}
- (void)detailQueryHandler:(NSString *)search {
   super.forSegue = [self parseData:[self requetPersonDetails:((Person *)super.forSegue).identifier]];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.destinationViewController isKindOfClass:[DetailViewController class]]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *detail = [(Person *)super.forSegue createDetail];
        UIImage *placeholder = [UIImage imageNamed:@"avatar"];
        [self performSelectorInBackground:@selector(detailQueryHandler:) withObject:((Person *) super.forSegue).identifier];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        //[((DetailViewController *)segue.destinationViewController) configureUsingCover:placeholder title:((Person *) super.forSegue).name sub:((Person *) super.forSegue).organization detail:detail];
    }
}


@end

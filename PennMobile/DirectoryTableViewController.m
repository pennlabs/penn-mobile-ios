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
-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self addContact:(Person *)super.objects[indexPath.row]];
}
- (void)queryHandler:(NSString *)search {
    [self importData:[self searchFor:search split:NO]];
    [self performSelectorOnMainThread:@selector(reloadView) withObject:nil waitUntilDone:NO];
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
    super.forSegue = super.objects[indexPath.row];
    //[self performSegueWithIdentifier:@"detail" sender:self];
    [self prompt:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length <= 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Search" message:@"Please search by at least 3 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        [super.searchBar resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.tableView.userInteractionEnabled = NO;
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
        //CLS_LOG(@"Data parameter was nil for query..returning null");
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
-(IBAction)prompt:(id)sender {
    Person *p = super.forSegue;
    UIAlertView *phoneAlert = [[UIAlertView alloc] initWithTitle:p.name message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
    if (p.phone && ![p.phone isEqualToString:@""]) {
        [phoneAlert addButtonWithTitle:@"Call"];
        [phoneAlert addButtonWithTitle:@"Text"];
    }
    if (p.email && ![p.email isEqualToString:@""]) {
        [phoneAlert addButtonWithTitle:@"Email"];
    }
    if ((!p.email || [p.email isEqualToString:@""]) && (!p.phone || [p.phone isEqualToString:@""])) {
        phoneAlert.message = @"This person has no public information listed";
    } else {
        [phoneAlert addButtonWithTitle:@"Add to Contacts"];
    }
    [phoneAlert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    Person *p = super.forSegue;
    NSString *phoneNumber = [@"tel://" stringByAppendingString:p.phone];
    NSString *textNumber = [@"sms://" stringByAppendingString:p.phone];
    NSString *email = [@"mailto://" stringByAppendingString:p.email];
    switch (buttonIndex) {
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            break;
        case 2:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:textNumber]];
            break;
        case 3:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
            break;
        case 4:
            [self addContact:p];
            break;
    }
}

#pragma mark -
#pragma mark Address Book Access

static ABAddressBookRef addressBook;

- (void)addContact:(Person *)inQuestion {
    [self requestAddressBookAccess:inQuestion];
}
- (void)accessGrantedForAddressBook:(Person *)inQuestion {
    [self showNewPersonViewController:inQuestion];
}
// Check the authorization status of our application for Address Book
-(void)checkAddressBookAccess:(Person *)inQuestion
{
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            [self accessGrantedForAddressBook:inQuestion];
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined:
            [self requestAddressBookAccess:inQuestion];
            break;
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Contacts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Address Book data
- (void)requestAddressBookAccess:(Person *)inQuestion
{
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self accessGrantedForAddressBook:inQuestion];
            });
        }
    });
}
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController
       didCompleteWithNewPerson:(ABRecordRef)person {
    NSString *name = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    if (name) {
        name = [name stringByAppendingString:@" was successfully added to your contacts."];
        UIAlertView *toShow = [[UIAlertView alloc] initWithTitle:@"Contact Added" message:name delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [newPersonViewController dismissViewControllerAnimated:YES completion:^{
            [toShow show];
        }];
    } else {
        [newPersonViewController dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)showNewPersonViewController:(Person *)inQuestion
{
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    picker.newPersonViewDelegate = self;
    ABRecordRef person = ABPersonCreate();
    if (inQuestion.phone) {
        ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(inQuestion.phone) ,kABPersonPhoneMobileLabel, NULL);
        ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil); // set the phone number property
    } if (inQuestion.email) {
        ABMutableMultiValueRef emailMulti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailMulti, (__bridge CFTypeRef)(inQuestion.email) ,kABWorkLabel, NULL);
        ABRecordSetValue(person, kABPersonEmailProperty, emailMulti, nil); // set the phone number property
    }
    NSArray *nameSplit = [inQuestion.name componentsSeparatedByString:@","];
    NSString *first = [nameSplit[1] substringToIndex:((NSString *)nameSplit[1]).length - 1];
    first = [first substringFromIndex:1];
    NSString *last = nameSplit[0];
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(first), nil); // first name of the new person
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(last), nil); // his last name
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:picker];
    picker.displayedPerson = person;
    [self presentViewController:navigation animated:YES completion:nil];
}

#pragma mark - Navigation
/**
 * This fragment is repeated across the app, still don't know the best way to refactor
 **/
- (IBAction)menuButton:(id)sender {
    if ([SlideOutMenuViewController instance].menuOut) {
        // this is a workaround as the normal returnToView selector causes a fault
        // the memory for hte instance is locked unless the view controller is passed in a segue
        // this is for security reasons.
        [[SlideOutMenuViewController instance] performSegueWithIdentifier:@"Directory" sender:self];
    } else {
        [self performSegueWithIdentifier:@"menu" sender:self];
    }
}
- (void)handleRollBack:(UIStoryboardSegue *)segue {
    if ([segue.destinationViewController isKindOfClass:[SlideOutMenuViewController class]]) {
        SlideOutMenuViewController *menu = segue.destinationViewController;
        cancelTouches = [[UITapGestureRecognizer alloc] initWithTarget:menu action:@selector(returnToView:)];
        cancelTouches.cancelsTouchesInView = YES;
        cancelTouches.numberOfTapsRequired = 1;
        cancelTouches.numberOfTouchesRequired = 1;
        if (self.view.gestureRecognizers.count > 0) {
            // there is a keybaord dismiss tap recognizer present
            // ((UIGestureRecognizer *) self.view.gestureRecognizers[0]).enabled = NO;
        }
        float width = [[UIScreen mainScreen] bounds].size.width;
        float height = [[UIScreen mainScreen] bounds].size.height;
        UIView *grayCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [grayCover setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        [grayCover addGestureRecognizer:cancelTouches];
        [UIView transitionWithView:self.view duration:1
                           options:UIViewAnimationOptionShowHideTransitionViews
                        animations:^ { [self.view addSubview:grayCover]; }
                        completion:nil];
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    [self handleRollBack:segue];

    if ([segue.destinationViewController isKindOfClass:[DetailViewController class]]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.tableView.userInteractionEnabled = NO;
        NSString *detail = [(Person *)super.forSegue createDetail];
        UIImage *placeholder = [UIImage imageNamed:@"avatar"];
        [self performSelectorInBackground:@selector(detailQueryHandler:) withObject:((Person *) super.forSegue).identifier];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.tableView.userInteractionEnabled = YES;
        //[((DetailViewController *)segue.destinationViewController) configureUsingCover:placeholder title:((Person *) super.forSegue).name sub:((Person *) super.forSegue).organization detail:detail];
    }
}


@end

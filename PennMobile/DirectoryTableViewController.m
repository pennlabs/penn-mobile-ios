//
//  DirectoryTableViewController.m
//  PennMobile
//
//  Created by Sacha Best on 9/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "DirectoryTableViewController.h"

@interface DirectoryTableViewController ()

@property (nonatomic, strong) NSMutableArray *resultsArray;
@property (nonatomic, strong) NSIndexPath *expandedIndexPath;
@property (nonatomic, strong) Person *currPerson;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DirectoryTableViewController

-(id) init {
    self = [super init];
    if(self) {
        self.title = @"Directory";
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.directorySearchBar becomeFirstResponder];
    
    self.navigationController.navigationBar.tintColor = PENN_YELLOW;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
}

-(void) viewDidLoad {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                         style:UIBarButtonItemStylePlain
                                        target:revealController
                                        action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    self.directorySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, width, 44)];
    self.directorySearchBar.delegate = self;
    [self.view addSubview:self.directorySearchBar];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 108, width, height-108)
                                                  style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.currPerson = [[Person alloc] init];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.resultsArray.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        return 132.0;
    }
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:nil];
    }
    
    if (indexPath.row <= self.resultsArray.count) {
        Person *person = (Person *)[self.resultsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [person.name capitalizedString];
    }
    
    cell.detailTextLabel.numberOfLines = 0;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView
 willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadRowsAtIndexPaths:@[indexPath]
                     withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [tableView beginUpdates];
    
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        self.expandedIndexPath = nil;
        [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = @"";
    } else {
        
        [self.tableView cellForRowAtIndexPath:self.expandedIndexPath].detailTextLabel.text = @"";
        
        self.expandedIndexPath = indexPath;
        Person *p = (Person *)[self.resultsArray objectAtIndex:indexPath.row];
        if(p) {
            NSString *desc = [NSString stringWithFormat:@"%@ -- ",
                              [[p.organization capitalizedString]stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]]];
            if(p.title) {
                desc = [desc stringByAppendingString:
                        [p.affiliation capitalizedString]];
            }
            if(p.email) {
                desc = [desc stringByAppendingString:
                        [NSString stringWithFormat:@"\n%@", [p.email lowercaseString]]];
            }
            if(p.phone) {
                desc = [desc stringByAppendingString:
                        [NSString stringWithFormat:@"\n%@", p.phone]];
            }
            [self.tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text = desc;
        }
        
    }
    
    [tableView endUpdates];
}

-(void)tableView:(UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    Person *p = [self.resultsArray objectAtIndex: indexPath.row];
    self.currPerson = p;
    
    UIAlertView *phoneAlert = [[UIAlertView alloc] initWithTitle:[p.name capitalizedString]
                                                         message:@""
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:nil];
    
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

#pragma mark - Search Bar Information

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length <= 2) {
        [SVProgressHUD showErrorWithStatus:@"Invalid Search. Search by at least 3 characters."];
    } else {
        [self.directorySearchBar resignFirstResponder];
        [SVProgressHUD show];
        self.tableView.userInteractionEnabled = NO;
        [super performSelectorInBackground:@selector(queryHandler:) withObject:searchBar.text];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 2) {
        [super performSelectorInBackground:@selector(queryHandler:) withObject:searchText];
    }
    if(![self.directorySearchBar isFirstResponder]) {
        [self searchBarCancelButtonClicked:self.directorySearchBar];
    }
}

#pragma mark - Alerts Information

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    Person *p = self.currPerson;
    NSString *email = [@"mailto://" stringByAppendingString:p.email];
    NSString *buttonTtile = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTtile isEqualToString:@"Email"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        
    } else if ([buttonTtile isEqualToString:@"Add to Contacts"]) {
        [self addContact:p];
    }
}


#pragma mark - API Stuff

- (void)queryHandler:(NSString *)search {
    
    NSArray *data = [self queryAPI:search];
    if(data) {
        [self parseData: data];
    }
    
    [self.tableView reloadData];
    self.tableView.userInteractionEnabled = YES;
    [SVProgressHUD dismiss];
}

-(NSArray *)queryAPI:(NSString *)term {
    
    term = [term stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSURL *url = [NSURL URLWithString:
                      [NSString stringWithFormat:@"%@%@%@", SERVER_ROOT, DIRECTORY_PATH, term]];
    NSData *result = [NSData dataWithContentsOfURL:url];
    if (!result) {
        [SVProgressHUD showErrorWithStatus:@"No results. Please try a different search term."];
        return nil;
    }
    
    NSError *error;
    NSDictionary *returned = [NSJSONSerialization JSONObjectWithData:result
                                                             options:NSJSONReadingMutableLeaves
                                                               error:&error];
    if (error) {
        [SVProgressHUD showErrorWithStatus:
            [NSString stringWithFormat:@"JSON parse error: %@",error.localizedDescription]];
        return nil;
    }
    
    return returned[@"result_data"];
}

- (NSMutableArray *) parseData:(NSArray *) data {
    self.resultsArray = [[NSMutableArray alloc] init];
    NSMutableArray *idArray = [[NSMutableArray alloc] init];
    for(NSMutableDictionary *dict in data) {
        Person *newPerson = [self parsePerson:dict];
        if(![idArray containsObject: newPerson.identifier]) {
            [self.resultsArray addObject:newPerson];
            [idArray addObject:newPerson.identifier];
        }
    }
    return self.resultsArray;
}

- (Person *)parsePerson:(NSDictionary *)data {
    Person *new = [[Person alloc] init];
    new.name = data[@"list_name"];
    new.title = data[@"list_title_or_major"];
    new.email = data[@"list_email"];
    new.phone = data[@"list_phone"];
    new.organization = data[@"list_organization"];
    new.affiliation = data[@"list_affiliation"];
    new.identifier = data[@"person_id"];
    return new;
}

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
            UIAlertView *alert =
                [[UIAlertView alloc] initWithTitle:@"Privacy Warning"
                                           message:@"Permission was not granted for Contacts."
                                          delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
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
        UIAlertView *toShow =
            [[UIAlertView alloc] initWithTitle:@"Contact Added"
                                       message:name
                                      delegate:self
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil, nil];
        [newPersonViewController dismissViewControllerAnimated:YES completion:^{
            [toShow show];
        }];
    } else {
        [newPersonViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)showNewPersonViewController:(Person *)inQuestion {
    ABNewPersonViewController *picker = [[ABNewPersonViewController alloc] init];
    picker.newPersonViewDelegate = self;
    ABRecordRef person = ABPersonCreate();
    if (inQuestion.phone) {
        ABMutableMultiValueRef phoneNumberMultiValue =
            ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue,
                                     (__bridge CFTypeRef)(inQuestion.phone),
                                     kABPersonPhoneMobileLabel,
                                     NULL);
        // set the phone number property
        ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
    } if (inQuestion.email) {
        ABMutableMultiValueRef emailMulti = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailMulti,
                                     (__bridge CFTypeRef)(inQuestion.email),
                                     kABWorkLabel,
                                     NULL);
         // set the phone number property
        ABRecordSetValue(person, kABPersonEmailProperty, emailMulti, nil);
    }
    NSArray *nameSplit = [inQuestion.name componentsSeparatedByString:@","];
    NSString *first = [nameSplit[1] substringToIndex:((NSString *)nameSplit[1]).length - 1];
    first = [first substringFromIndex:1];
    NSString *last = nameSplit[0];
    // First name
    ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)(first), nil);
    // Last name
    ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)(last), nil);
    UINavigationController *navigation =
        [[UINavigationController alloc] initWithRootViewController:picker];
    picker.displayedPerson = person;
    [self presentViewController:navigation animated:YES completion:nil];
}


@end

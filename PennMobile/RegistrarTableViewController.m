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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - API

-(NSArray *)queryAPI:(NSString *)term {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", SERVER_ROOT, REGISTRAR_PATH, term]];
    NSData *result = [NSData dataWithContentsOfURL:url];
    if (![self confirmConnection:result]) {
        return nil;
    }
    if (!result) {
        CLS_LOG(@"Data parameter was nil for query..proceeding anyway");
    }
    NSError *error;
    NSDictionary *returned = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        [NSException raise:@"JSON parse error" format:@"%@", error];
    }
    return returned[@"courses"];
}
-(void)importData:(NSArray *)raw {
    for (NSDictionary *courseData in raw) {
        Course *new = [[Course alloc] init];
        new.identifier = courseData[@"_id"];
        new.dept = courseData[@"course_department"];
        new.title = [courseData[@"course_title"] capitalizedString];
        new.courseNum = courseData[@"course_number"];
        new.credits = courseData[@"credits"];
        new.sectionNum = courseData[@"section_number"];
        new.desc = courseData[@"course_description"];
        new.type = [courseData[@"type"] capitalizedString];
        new.times = courseData[@"times"];
        if (courseData[@"meetings"] && ((NSArray *)courseData[@"meetings"]).count > 0)
            new.building = courseData[@"meetings"][0][@"buildingName"];
        new.roomBum = courseData[@"roomNumber"];
        NSMutableArray *profs = [[NSMutableArray alloc] init];
        for (NSDictionary *prof in courseData[@"instructors"]) {
            [profs addObject:prof[@"name"]];
        }
        new.professors = [profs copy];
        [tempSet addObject:new];
    }
    super.objects = [tempSet sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int courseNum1 = [((Course *)obj1).courseNum intValue];
        int courseNum2 = [((Course *)obj2).courseNum intValue];
        return courseNum1 > courseNum2;
    }];
    if (tempSet && tempSet.count > 0)
        [tempSet removeAllObjects];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return super.objects.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    super.forSegue = super.objects[indexPath.row];
    [self performSegueWithIdentifier:@"detail" sender:self];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RegistrarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"class" forIndexPath:indexPath];
    Course *inQuestion = super.objects[indexPath.row];
    cell.labelName.text = inQuestion.title;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.labelNumber.text = [NSString stringWithFormat:@"%@ %@", inQuestion.dept, inQuestion.courseNum];
    if (inQuestion.professors && inQuestion.professors.count > 0) {
        cell.labelProf.text = inQuestion.professors[0];
    }
    CGRect cellFrame = cell.textLabel.frame;
    cell.textLabel.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, 20.0f, cellFrame.size.height);
    return cell;
}
- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText {
    if(![super.searchBar isFirstResponder]) {
        [self searchBarCancelButtonClicked:super.searchBar];
    }
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
        Course *forSegue = super.forSegue;
        NSString *detail = [forSegue createDetail];
        NSString *prof = Nil;
        if (forSegue.professors && forSegue.professors.count > 0) {
            prof = forSegue.professors[0];
        }
        if (forSegue.building) {
            [((DetailViewController *)segue.destinationViewController) configureUsingCover:forSegue.building title:forSegue.title sub:prof number:forSegue.courseNum credits:forSegue.credits detail:detail];
        } else {
            [((DetailViewController *)segue.destinationViewController) configureUsingCover:@"" title:forSegue.title sub:prof number:forSegue.courseNum credits:forSegue.credits detail:detail];
        }
    }
}

@end

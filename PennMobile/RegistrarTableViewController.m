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
    
    buildings = [[NSMutableDictionary alloc] init];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)courseFilterSwitch:(id)sender {
    currentFilter = (CourseFilter) _filterSwitch.selectedSegmentIndex + 1;
    if (!super.searchBar.isFirstResponder && super.searchBar.text && super.searchBar.text.length > 0) {
        [super searchTemplate];
    }
}
#pragma mark - API

-(NSArray *)queryAPI:(NSString *)term {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", SERVER_ROOT, REGISTRAR_PATH, term]];
    NSData *result = [NSData dataWithContentsOfURL:url];
    if (![self confirmConnection:result]) {
        return nil;
    }
    if (!result) {
        //CLS_LOG(@"Data parameter was nil for query..proceeding anyway");
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
        NSString *activityType = courseData[@"activity_description"];
        if (currentFilter == Recitation) {
            if (![activityType isEqualToString:@"Recitation"]) {
                continue;
            }
        } else if (currentFilter == Lab) {
            if (![activityType isEqualToString:@"Laboratory"]) {
                continue;
            }
        } else if (currentFilter == Lecture) {
            if (![activityType isEqualToString:@"Lecture"]) {
                continue;
            }
        }
        Course *new = [[Course alloc] init];
        /* Unused
        NSString *term = courseData[@"term"];
        long pcrYear = [[courseData[@"term"] substringToIndex:(term.length -1)] intValue] - 1;
        NSString *semester = [term substringFromIndex:term.length - 1];
         */
        new.activity = courseData[@"activity_description"];
        new.dept = courseData[@"course_department"];
        new.title = courseData[@"course_title"];
        new.courseNum = courseData[@"course_number"];
        new.credits = courseData[@"credits"];
        new.sectionNum = courseData[@"section_number"];
        new.desc = courseData[@"course_description"];
        new.type = [courseData[@"type"] capitalizedString];
        new.roomBum = courseData[@"roomNumber"];
        new.sectionID = courseData[@"section_id_normalized"];
        new.primaryProf = courseData[@"primary_instructor"];
        new.identifier = [NSString stringWithFormat:@"%@-%@", new.dept, new.courseNum];
        if (courseData[@"meetings"] && ((NSArray *)courseData[@"meetings"]).count > 0) {
            NSArray *mtgs = ((NSArray *)courseData[@"meetings"]);
            int c;
            NSString *toBuild = @"";
            for (c = 0; c < mtgs.count - 1; c++) {
                toBuild = [toBuild stringByAppendingFormat:@"%@ %@ - %@ | ", mtgs[c][@"meeting_days"], mtgs[c][@"start_time"], mtgs[c][@"end_time"]];
            }
            toBuild = [toBuild stringByAppendingFormat:@"%@ %@ - %@.", mtgs[c][@"meeting_days"], mtgs[c][@"start_time"], mtgs[c][@"end_time"]];
            new.times = toBuild;
            new.building = courseData[@"meetings"][0][@"building_name"];
            new.buildingCode = courseData[@"meetings"][0][@"building_code"];
            new.roomBum = courseData[@"meetings"][0][@"room_number"];
            if (new.buildingCode && ![new.buildingCode isEqualToString:@""]) {
                if (buildings[new.buildingCode]) {
                    MKPointAnnotation *pt = buildings[new.buildingCode];
                    MKPointAnnotation *newPt = [[MKPointAnnotation alloc] init];
                    newPt.title = [[new.building stringByAppendingString:@" "]     stringByAppendingString:new.roomBum];
                    newPt.coordinate = pt.coordinate;
                    new.point = newPt;
                    // this because MKPointAnimation does not implement copying
                } else {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", SERVER_ROOT, BUILDING_PATH, new.buildingCode]];
                    NSData *result = [NSData dataWithContentsOfURL:url];
                    NSError *error;
                    @try {
                        NSDictionary *returned = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
                        if (error) {
                            [NSException raise:@"JSON parse error" format:@"%@", error];
                        } else {
                            float lat = [returned[@"latitude"] doubleValue];
                            float lon = [returned[@"longitude"] doubleValue];
                            MKPointAnnotation *pt = [[MKPointAnnotation alloc] init];
                            pt.coordinate = CLLocationCoordinate2DMake(lat, lon);
                            pt.title = [[new.building stringByAppendingString:@" "]     stringByAppendingString:new.roomBum];
                            new.point = pt;
                            buildings[new.buildingCode] = pt;
                        }
                    }
                    @catch (NSException *e) {
                        NSLog(@"No building found for %@", new.buildingCode);
                    }
                }
            }
        }
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
        int sectionNum1 = [((Course *)obj1).sectionNum intValue];
        int sectionNum2 = [((Course *)obj2).sectionNum intValue];
        if (courseNum1 == courseNum2) {
            return sectionNum1 > sectionNum2;
        }
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    super.forSegue = super.objects[indexPath.row];
    selected = indexPath;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ((Course *) super.forSegue).review = [PCRAggregator getAverageReviewFor:((Course *)super.forSegue)];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self performSegueWithIdentifier:@"detail" sender:self];
        });
    });
}
- (void)queryHandler:(NSString *)search {
    [self importData:[self searchFor:search split:YES]];
    [self performSelectorOnMainThread:@selector(reloadView) withObject:nil waitUntilDone:NO];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RegistrarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"class" forIndexPath:indexPath];
    Course *inQuestion = super.objects[indexPath.row];
    cell.labelName.text = inQuestion.title;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.labelNumber.text = [NSString stringWithFormat:@"%@ %@ ", inQuestion.dept, inQuestion.courseNum];
    if (inQuestion.professors && inQuestion.professors.count > 0) {
        cell.labelProf.text = inQuestion.professors[0];
        if (inQuestion.professors.count > 1 && inQuestion.primaryProf && ![inQuestion.primaryProf isEqualToString:@""]) {
            cell.labelProf.text = inQuestion.primaryProf;
        }
    } else {
        cell.labelProf.text = @"No Professor Listed";
    }
    cell.labelSection.text = [NSString stringWithFormat:@"Section %@ - %@", inQuestion.sectionNum, inQuestion.activity];
    //CGRect cellFrame = cell.textLabel.frame;
    //cell.textLabel.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, 20.0f, cellFrame.size.height);
    return cell;
}
- (void)searchBar:(UISearchBar *)bar textDidChange:(NSString *)searchText {
    if(![super.searchBar isFirstResponder]) {
        [self searchBarCancelButtonClicked:super.searchBar];
    }
}
- (void)deselect {
    if (selected) {
        [self.tableView deselectRowAtIndexPath:selected animated:YES];
        selected = nil;
    }
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

@end

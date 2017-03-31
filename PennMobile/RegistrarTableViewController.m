//
//  RegistrarTableViewController.m
//  PennMobile
//
//  Created by Sacha Best on 9/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "RegistrarTableViewController.h"
#import "RegistrarDetailViewController.h"

@interface RegistrarTableViewController ()

typedef NS_ENUM(NSInteger, CourseFilter) {
    Lecture,
    Lab,
    Recitation,
    All,
};

@property (nonatomic, strong) NSIndexPath *selected;
@property (nonatomic, strong) NSMutableDictionary *buildings;
@property (nonatomic, strong) NSMutableArray *courses;
@property (nonatomic) CourseFilter currentFilter;
@property (nonatomic, strong) UISegmentedControl *filterSwitch;

@property (nonatomic, strong) UIToolbar *headerToolbar;
@property (nonatomic, strong) UIImageView *navBarHairlineImageView;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RegistrarTableViewController

-(id) init {
    self = [super init];
    if(self) {
        self.title = @"Courses";
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = PENN_YELLOW;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    self.navBarHairlineImageView =
    [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    [self.navBarHairlineImageView setHidden:YES];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navBarHairlineImageView.hidden = NO;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem =
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                         style:UIBarButtonItemStylePlain
                                        target:revealController
                                        action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    // self.buildings = [[NSMutableDictionary alloc] init];
    self.courses = [[NSMutableArray alloc] init];
    self.filteredCourses = [[NSMutableArray alloc] init];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    self.registrySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 108, width, 44)];
    self.registrySearchBar.delegate = self;
    [self.view addSubview:self.registrySearchBar];
    
    self.headerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 64, width, 44)];
    self.headerToolbar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    self.headerToolbar.delegate = self;
    
    self.filterSwitch =
        [[UISegmentedControl alloc] initWithItems: @[@"All", @"Lecture", @"Recitation", @"Lab"]];
    self.filterSwitch.center = CGPointMake(width/2, self.headerToolbar.frame.size.height/2);
    self.filterSwitch.tintColor = PENN_YELLOW;
    self.filterSwitch.selectedSegmentIndex = 0;
    [self.filterSwitch addTarget:self
                          action:@selector(switchFilter)
                forControlEvents:UIControlEventValueChanged];
    [self.headerToolbar addSubview:self.filterSwitch];
    [self.view addSubview:self.headerToolbar];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 152, width, height-152)
                                                  style:UITableViewStylePlain];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    
}

- (void)switchFilter {
    self.currentFilter = self.filterSwitch.selectedSegmentIndex;
    self.filteredCourses = [self filterCourses: self.courses];
    [self.tableView reloadData];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

#pragma mark - Search Bar Information

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length <= 2) {
        [SVProgressHUD showErrorWithStatus:@"Invalid Search. Search by at least 3 characters."];
    } else {
        [self.registrySearchBar resignFirstResponder];
        [SVProgressHUD show];
        self.tableView.userInteractionEnabled = NO;
        [super performSelectorInBackground:@selector(queryHandler:) withObject:searchBar.text];
    }
}

//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    if (searchText.length > 2) {
//        [super performSelectorInBackground:@selector(queryHandler:) withObject:searchText];
//    }
//    if(![self.registrySearchBar isFirstResponder]) {
//        [self searchBarCancelButtonClicked:self.registrySearchBar];
//    }
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredCourses.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//    super.forSegue = super.objects[indexPath.row];
//    selected = indexPath;
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        ((Course *) super.forSegue).review = [PCRAggregator getAverageReviewFor:((Course *)super.forSegue)];
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//            [self performSegueWithIdentifier:@"detail" sender:self];
//        });
//    });
    
    RegistrarDetailViewController *registrarDetailVC =
        [[RegistrarDetailViewController alloc] initWithCourse:[self.filteredCourses objectAtIndex:indexPath.item]];
    [self.navigationController pushViewController:registrarDetailVC animated:YES];
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"Cell"];
    }
    
    Course *cellCourse = (Course *)[self.filteredCourses objectAtIndex:indexPath.row];
    cell.textLabel.text = cellCourse.sectionID;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    // cell.detailTextLabel.text = cellCourse.title;
    
    //    Course *inQuestion = super.objects[indexPath.row];
    //    cell.labelName.text = inQuestion.title;
    //    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    //    cell.labelNumber.text = [NSString stringWithFormat:@"%@ %@ ", inQuestion.dept, inQuestion.courseNum];
    //    if (inQuestion.professors && inQuestion.professors.count > 0) {
    //        cell.labelProf.text = inQuestion.professors[0];
    //        if (inQuestion.professors.count > 1 && inQuestion.primaryProf && ![inQuestion.primaryProf isEqualToString:@""]) {
    //            cell.labelProf.text = inQuestion.primaryProf;
    //        }
    //    } else {
    //        cell.labelProf.text = @"No Professor Listed";
    //    }
    //    cell.labelSection.text = [NSString stringWithFormat:@"Section %@ - %@", inQuestion.sectionNum, inQuestion.activity];
    //    //CGRect cellFrame = cell.textLabel.frame;
    //    //cell.textLabel.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, 20.0f, cellFrame.size.height);
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

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - API

- (void)queryHandler:(NSString *)search {
    
    self.courses = [self queryAPI:search];
    self.filteredCourses = [self filterCourses:self.courses];
    
    [self.tableView reloadData];
    self.tableView.userInteractionEnabled = YES;
    [SVProgressHUD dismiss];
}

-(NSMutableArray *)queryAPI:(NSString *)term {
    NSURL *url =
        [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", SERVER_ROOT, REGISTRAR_PATH, term]];
    NSData *result = [NSData dataWithContentsOfURL:url];

//    if (![self confirmConnection:result]) {
//        return nil;
//    }
    if (!result) {
        //CLS_LOG(@"Data parameter was nil for query..proceeding anyway");
        [SVProgressHUD showErrorWithStatus:@"Cannot connect to internet or the API is down."];
        return [[NSMutableArray alloc] init];
    }
    NSError *error;
    NSDictionary *returned = [NSJSONSerialization JSONObjectWithData:result
                                                             options:NSJSONReadingMutableLeaves
                                                               error:&error];
    if (error) {
        [NSException raise:@"JSON parse error" format:@"%@", error];
    }
    
    NSMutableArray *courseList = [[NSMutableArray alloc] init];
    for(NSDictionary *courseData in [returned objectForKey:@"courses"]) {
        
        NSDictionary *meetings = [courseData[@"meetings"] firstObject];
        
        Course *new = [[Course alloc] init];
        new.activity = courseData[@"activity_description"];
        new.dept = courseData[@"course_department"];
        new.title = courseData[@"course_title"];
        new.courseNum = courseData[@"course_number"];
        new.credits = courseData[@"credits"];
        new.sectionNum = courseData[@"section_number"];
        new.desc = courseData[@"course_description"];
        new.roomNum = [NSString stringWithFormat: @"%@%@", meetings[@"building_code"], meetings[@"room_number"]];
        new.sectionID = [courseData[@"section_id_normalized"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        new.primaryProf = courseData[@"primary_instructor"];
        new.identifier = [NSString stringWithFormat:@"%@-%@", new.dept, new.courseNum];
        new.times = [NSString stringWithFormat: @"%@ %@-%@", meetings[@"meeting_days"],
                                                             meetings[@"start_time"],
                                                             meetings[@"end_time"]];
        new.review = [PCRAggregator getAverageReviewFor:new];

        [courseList addObject:new];
    }
    
    return courseList;
}

-(NSMutableArray *) filterCourses:(NSMutableArray *)courses {
    
    NSString *string;
    if (self.currentFilter == All) {
        return courses;
    } else if (self.currentFilter == Lecture) {
        string = @"Lecture";
    } else if (self.currentFilter == Lab) {
        string = @"Laboratory";
    } else if (self.currentFilter == Recitation) {
        string = @"Recitation";
    }
    
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    for (Course *course in courses) {
        if ([course.activity isEqualToString:string]) {
            [newList addObject:course];
        }
    }
    
    return newList;
}

//
//-(void)importData:(NSArray *)raw {
//    for (NSDictionary *courseData in raw) {
//        NSString *activityType = courseData[@"activity_description"];
//        if (currentFilter == Recitation) {
//            if (![activityType isEqualToString:@"Recitation"]) {
//                continue;
//            }
//        } else if (currentFilter == Lab) {
//            if (![activityType isEqualToString:@"Laboratory"]) {
//                continue;
//            }
//        } else if (currentFilter == Lecture) {
//            if (![activityType isEqualToString:@"Lecture"]) {
//                continue;
//            }
//        }
//        Course *new = [[Course alloc] init];
//        /* Unused
//        NSString *term = courseData[@"term"];
//        long pcrYear = [[courseData[@"term"] substringToIndex:(term.length -1)] intValue] - 1;
//        NSString *semester = [term substringFromIndex:term.length - 1];
//         */
//        new.activity = courseData[@"activity_description"];
//        new.dept = courseData[@"course_department"];
//        new.title = courseData[@"course_title"];
//        new.courseNum = courseData[@"course_number"];
//        new.credits = courseData[@"credits"];
//        new.sectionNum = courseData[@"section_number"];
//        new.desc = courseData[@"course_description"];
//        new.type = [courseData[@"type"] capitalizedString];
//        new.roomNum = courseData[@"roomNumber"];
//        new.sectionID = courseData[@"section_id_normalized"];
//        new.primaryProf = courseData[@"primary_instructor"];
//        new.identifier = [NSString stringWithFormat:@"%@-%@", new.dept, new.courseNum];
//        if (courseData[@"meetings"] && ((NSArray *)courseData[@"meetings"]).count > 0) {
//            NSArray *mtgs = ((NSArray *)courseData[@"meetings"]);
//            int c;
//            NSString *toBuild = @"";
//            for (c = 0; c < mtgs.count - 1; c++) {
//                toBuild = [toBuild stringByAppendingFormat:@"%@ %@ - %@ | ", mtgs[c][@"meeting_days"], mtgs[c][@"start_time"], mtgs[c][@"end_time"]];
//            }
//            toBuild = [toBuild stringByAppendingFormat:@"%@ %@ - %@.", mtgs[c][@"meeting_days"], mtgs[c][@"start_time"], mtgs[c][@"end_time"]];
//            new.times = toBuild;
//            new.building = courseData[@"meetings"][0][@"building_name"];
//            new.buildingCode = courseData[@"meetings"][0][@"building_code"];
//            new.roomNum = courseData[@"meetings"][0][@"room_number"];
//            if (new.buildingCode && ![new.buildingCode isEqualToString:@""]) {
//                if (buildings[new.buildingCode]) {
//                    MKPointAnnotation *pt = buildings[new.buildingCode];
//                    MKPointAnnotation *newPt = [[MKPointAnnotation alloc] init];
//                    newPt.title = [[new.building stringByAppendingString:@" "]     stringByAppendingString:new.roomNum];
//                    newPt.coordinate = pt.coordinate;
//                    new.point = newPt;
//                    // this because MKPointAnimation does not implement copying
//                } else {
//                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", SERVER_ROOT, BUILDING_PATH, new.buildingCode]];
//                    NSData *result = [NSData dataWithContentsOfURL:url];
//                    NSError *error;
//                    @try {
//                        NSDictionary *returned = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
//                        if (error) {
//                            [NSException raise:@"JSON parse error" format:@"%@", error];
//                        } else {
//                            float lat = [returned[@"latitude"] doubleValue];
//                            float lon = [returned[@"longitude"] doubleValue];
//                            MKPointAnnotation *pt = [[MKPointAnnotation alloc] init];
//                            pt.coordinate = CLLocationCoordinate2DMake(lat, lon);
//                            pt.title = [[new.building stringByAppendingString:@" "]     stringByAppendingString:new.roomNum];
//                            new.point = pt;
//                            buildings[new.buildingCode] = pt;
//                        }
//                    }
//                    @catch (NSException *e) {
//                        NSLog(@"No building found for %@", new.buildingCode);
//                    }
//                }
//            }
//        }
//        NSMutableArray *profs = [[NSMutableArray alloc] init];
//        for (NSDictionary *prof in courseData[@"instructors"]) {
//            [profs addObject:prof[@"name"]];
//        }
//        new.professors = [profs copy];
//        [tempSet addObject:new];
//    }
//    super.objects = [tempSet sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        int courseNum1 = [((Course *)obj1).courseNum intValue];
//        int courseNum2 = [((Course *)obj2).courseNum intValue];
//        int sectionNum1 = [((Course *)obj1).sectionNum intValue];
//        int sectionNum2 = [((Course *)obj2).sectionNum intValue];
//        if (courseNum1 == courseNum2) {
//            return sectionNum1 > sectionNum2;
//        }
//        return courseNum1 > courseNum2;
//    }];
//    if (tempSet && tempSet.count > 0)
//        [tempSet removeAllObjects];
//}
//
//-(IBAction)courseFilterSwitch:(id)sender {
//    currentFilter = (CourseFilter) _filterSwitch.selectedSegmentIndex + 1;
//    if (!super.searchBar.isFirstResponder && super.searchBar.text && super.searchBar.text.length > 0) {
//        [super searchTemplate];
//    }
//}

@end

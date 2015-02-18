//
//  BuildingViewController.m
//  PennMobile
//
//  Created by Sacha Best on 2/12/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "BuildingViewController.h"

@interface BuildingViewController ()

@end

@implementation BuildingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
    }
    _mapView.showsUserLocation = YES;
    [_mapView setMapType:MKMapTypeStandard];
    [_mapView setZoomEnabled:YES];
    [_mapView setScrollEnabled:YES];
    results = [[NSMutableArray alloc] init];
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    if (self.locationManager.location) {
        hasCentered = YES;
    }
    [self centerMapOnLocation];
}
- (void)centerMapOnLocation {
    //View Area
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.005f;
    region.span.longitudeDelta = 0.005f;
    [_mapView setRegion:region animated:YES];
}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (!hasCentered) {
        [self centerMapOnLocation];
        hasCentered = YES;
    }
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
    }
}
- (void)plotPoints {
    if (results.count > 0) {
        for (int i = results.count - 1; i > 0; i--) {
            [_mapView addAnnotation:((Building *) results[i]).mapPoint];
        }
        [_mapView addAnnotation:((Building *) results[0]).mapPoint];
        [_mapView selectAnnotation:((Building *) results[0]).mapPoint animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length <= 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Search" message:@"Please search by at least 3 characters." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else {
        [_mapView removeAnnotations:_mapView.annotations];
        [_searchBar resignFirstResponder];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [super performSelectorInBackground:@selector(queryHandler:) withObject:searchBar.text];
    }
}
/** Disabling search as you type fo rnow...
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length > 2) {
        [super performSelectorInBackground:@selector(queryHandler:) withObject:searchText];
    }
    if(![_searchBar isFirstResponder]) {
        [self searchBarCancelButtonClicked:_searchBar];
    }
}
 */
- (void)queryHandler:(NSString *)term {
    NSArray *res = [self queryAPI:term];
    [self parseData:res];
}

-(NSArray *)queryAPI:(NSString *)term {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", SERVER_ROOT, BUILDING_PATH, [term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
]];
    NSData *result = [NSData dataWithContentsOfURL:url];
    if (![self confirmConnection:result]) {
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
// This try catch should be copied to other views
- (void)parseData:(NSArray *)data {
    if (results && results.count > 0) {
        @try {
            [results removeAllObjects];
        }
        @catch (NSException *exception) {
            // TBD
            // this is caused by a concurrent access
            // i.e. removeAllObjects is called too many times
        }
    }
    bool exceptionCaught = false;
    NSString *exceptionMsg;
    for (NSDictionary *bldgData in data) {
        Building *new = [[Building alloc] init];
        @try {
            new.code = bldgData[@"building_code"];
            new.name = bldgData[@"title"];
            new.addressStreet = bldgData[@"address"];
            new.addressCity = bldgData[@"city"];
            new.addressState = bldgData[@"state"];
            new.zip = bldgData[@"zip_code"];
            [new setCoordAndGenerate:CLLocationCoordinate2DMake([bldgData[@"latitude"] floatValue], [bldgData[@"longitude"] floatValue])];
            new.yearBuilt = bldgData[@"year_built"];
            new.link = [NSURL URLWithString:bldgData[@"http_link"]];
            
            // usually max of 2 images
            NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:2];
            
            for (NSDictionary *img in bldgData[@"campus_item_images"]) {
                [images addObject:img[@"image_url"]];
            }
            new.images = images;
            [results addObject:new];
        }
        @catch (NSException *exception) {
            exceptionCaught = YES;
            exceptionMsg = exception.reason;
        }
        @finally {
            // insert code here that should be executed post exception catch
        }
    }

    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    if (exceptionCaught) {
        UIAlertView *err = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:[NSString stringWithFormat:@"There was an error connecting to the PennLabs server. Please try again later.\n%@", exceptionMsg] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [err show];
    }
    [self performSelectorOnMainThread:@selector(plotPoints) withObject:nil waitUntilDone:NO];
}

- (BOOL)confirmConnection:(NSData *)data {
    if (!data) {
        UIAlertView *new = [[UIAlertView alloc] initWithTitle:@"Couldn't Connect to API" message:@"We couldn't connect to Penn's API. Please try again later. :(" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [new show];
        return false;
    }
    return true;
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
        [[SlideOutMenuViewController instance] performSegueWithIdentifier:@"Courses" sender:self];
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
    if ([segue.identifier isEqualToString:@"detail"]) {
        DetailViewController *destination = segue.destinationViewController;
        destination.building = selected;
    }
}


@end

//
//  DetailViewController.m
//  PennMobile
//
//  Created by Sacha Best on 10/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

static MKLocalSearchRequest *req;
static MKLocalSearch *search;

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageCover.contentMode = UIViewContentModeScaleAspectFill;
    _mapCover.hidden = YES;
    _imageCover.hidden = NO;
    if (coverUIImage) {
        _mapCover.hidden = YES;
        _imageCover.hidden = NO;
        _imageCover.image = coverUIImage;
    } else {
        _mapCover.hidden = NO;
        _imageCover.hidden = YES;
        _mapCover.showsUserLocation = YES;
    }
    [_viewTitle.layer setMasksToBounds:YES];
    [_viewTitle.layer setCornerRadius:20.0f];
    _titleText.text = info.title;
    _detailText.text = info.desc;
    [_courseNumber.layer setMasksToBounds:YES];
    _courseNumber.layer.cornerRadius = BORDER_RADIUS;
    _courseNumber.text = [[info.dept stringByAppendingString:@" "] stringByAppendingString:info.courseNum];
    if (info.professors && info.professors.count > 0)
        _subText.text = info.professors[0];
    _credits.text = info.credits;
    _sectionNum.text = [@"Section " stringByAppendingString:info.sectionNum];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissModalViewControllerAnimated:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!_mapCover.hidden) {
        if (!center) {
            CLLocation *user = _mapCover.userLocation.location;
            if (!user) {
                user = [[CLLocation alloc] initWithLatitude:39.9520689 longitude:-75.1910786];
            }
            [_mapCover setCenterCoordinate:user.coordinate animated:YES];
            _mapCover.region = MKCoordinateRegionMakeWithDistance(user.coordinate, kMapSize, kMapSize);
        }
        else {
            [_mapCover setCenterCoordinate:center.placemark.coordinate animated:YES];
            _mapCover.region = MKCoordinateRegionMakeWithDistance(center.placemark.location.coordinate, kMapSize, kMapSize);
        }
    }
   // [self startStandardUpdates];
}
- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (!locationManager)
        locationManager = [[CLLocationManager alloc] init];
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500; // meters
    
    [locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    [_mapCover setCenterCoordinate:location.coordinate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureUsingCover:(id)cover title:(NSString *)title sub:(NSString *)sub number:(NSString *)num credits:(NSString *)credits detail:(NSString *)detail {
    if ([cover isKindOfClass:[UIImage class]]) {
        UIImage *coverImage = cover;
        coverUIImage = coverImage;
        //titleText = title;
        //detailText = detail;
        //if (sub)
          //  subText = sub;
        
    } else if ([cover isKindOfClass:[NSString class]]) {
        [DetailViewController searchForBuilding:cover sender:self completion:@selector(setupMap:)];
        //titleText = title;
        //detailText = detail;
        //if (sub)
          //  subText = sub;
        _credits.text = [credits stringByAppendingString:@" CU"];
        _courseNumber.text = num;
    } else {
        [NSException raise:@"Invalid DetailView Configuation" format:@"Type %@ passed. Expecting MKMapItem or UIImage.", [cover class]];
    }
}
-(void)configureWithCourse:(Course *)course {
    info = course;
}
- (void)setupMap:(MKMapItem *)point {
    center = point;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

+ (void)searchForBuilding:(NSString *)query sender:(id)sender completion:(SEL)completion {
    if (!req) {
        req = [[MKLocalSearchRequest alloc] init];
        req.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(39.952219, -75.193214), MKCoordinateSpanMake(10, 10));
    }
    // for no building location
    if ([query isEqualToString:@""]) {
        [sender performSelector:completion withObject:nil];
    }
    req.naturalLanguageQuery = query;
    search = [[MKLocalSearch alloc] initWithRequest:req];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count > 0)
            [sender performSelector:completion withObject:response.mapItems[0]];
    }];
}
@end

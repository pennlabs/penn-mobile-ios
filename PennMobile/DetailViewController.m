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
    if (building) {
        _mapCover.hidden = YES;
        _imageCover.hidden = NO;
        //_imageCover.image = coverUIImage;
        [self setupForBuilding];
    } else {
        _mapCover.hidden = NO;
        _buttonRoute.hidden = YES;
        _buttonRoute.enabled = NO;
        _imageCover.hidden = YES;
        _mapCover.showsUserLocation = YES;
        [self setupForCourse];
    }
    [_viewTitle.layer setMasksToBounds:YES];
    [_viewTitle.layer setCornerRadius:20.0f];
       _detailText.font = [UIFont systemFontOfSize:15.0];
    [_courseNumber.layer setMasksToBounds:YES];
    _courseNumber.layer.cornerRadius = BORDER_RADIUS;
    [_backButton.layer setMasksToBounds:YES];
    [_backButton.layer setCornerRadius:BORDER_RADIUS];
}
- (void)setupForCourse {
    _titleText.text = info.title;
    _detailText.text = info.desc;
    _labelTime.text = info.times;
    _courseNumber.text = [[info.dept stringByAppendingString:@" "] stringByAppendingString:info.courseNum];
    if (info.professors && info.professors.count > 0) {
        _subText.text = info.professors[0];
        if (info.professors.count > 1 && info.primaryProf && ![info.primaryProf isEqualToString:@""]) {
            _subText.text = info.primaryProf;
        }
    }
    _credits.text = info.credits;
    _sectionNum.text = [@"Section " stringByAppendingString:info.sectionNum];
    [self startStandardUpdates];
}
- (void)setupForBuilding {
    _titleBuilding.hidden = NO; 
    _titleBuilding.text = building.name;
    [_titleBuilding setContentOffset:CGPointZero animated:NO];
    _buttonRoute.hidden = NO;
    _titleText.text = [building generateFullAddress:YES];
    if (_titleText.text.length > 0) {
        _courseNumber.hidden = YES;
        _buttonRoute.enabled = YES;
    }
    _courseDetailView.hidden = YES;
    //descFrameUpdate = CGRectMake(_detailText.frame.origin.x, _labelTime.frame.origin.y, _detailText.frame.size.width, _detailText.frame.size.height);
    //_detailText.frame = descFrameUpdate;
    _detailText.text = building.desc;
    _courseNumber.text = building.code;
    _labelTime.text = building.keywords;
    //_subText.lineBreakMode = NSLineBreakByWordWrapping;
    _subText.numberOfLines = 2;
    [building loadImageWithBlock:^(UIImage *img) {
        _imageCover.image = img;
    }];
}

-(IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.presentingViewController performSelector:@selector(deselect)];
    }];
}
-(IBAction)route:(id)sender {
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:building.mapPoint.coordinate addressDictionary: [building generateAddressDictionary]];
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
    destination.name = building.name;
    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                             MKLaunchOptionsDirectionsModeDriving,
                             MKLaunchOptionsDirectionsModeKey, nil];
    [MKMapItem openMapsWithItems: items launchOptions: options];
}
- (void)viewDidAppear:(BOOL)animated {
    if (info) {
        [self dealWithAppleMaps];
    } else {
        // correction to iOS 7 UITextView Font bug
        // fix to iOS 7 ScrollView Bug
        _titleBuilding.selectable = NO;
        [_titleBuilding setContentOffset:CGPointZero animated:NO];
    }
    [_detailText setContentOffset:CGPointMake(0, -_detailText.contentInset.top) animated:NO];
}

- (void)dealWithAppleMaps {
    if (!_mapCover.hidden) {
        CLLocation *user = [[CLLocation alloc] initWithLatitude:39.9520689 longitude:-75.1910786];
        _mapCover.region = MKCoordinateRegionMakeWithDistance(user.coordinate, kMapSize, kMapSize);
        if (info.building) {
            [_mapCover setCenterCoordinate:info.point.coordinate animated:YES];
            [_mapCover addAnnotation:info.point];
            [_mapCover selectAnnotation:info.point animated:YES];
        } else {
            _noLoc.hidden = NO;
            CLLocation *user = _mapCover.userLocation.location;
            if (!user) {
                user = [[CLLocation alloc] initWithLatitude:39.9520689 longitude:-75.1910786];
            }
            [_mapCover setCenterCoordinate:user.coordinate animated:YES];
            _mapCover.region = MKCoordinateRegionMakeWithDistance(user.coordinate, kMapSize, kMapSize);
        }
    }

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
-(void)configureUsingBuilding:(Building *)bldg {
    building = bldg;
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

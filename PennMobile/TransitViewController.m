//
//  TransitViewController.m
//  PennMobile
//
//  Created by Sacha Best on 9/30/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "TransitViewController.h"

@interface TransitViewController ()

@end

@implementation TransitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [locationManager requestWhenInUseAuthorization];
    }
    _mapView.showsUserLocation = YES;
    [_mapView setMapType:MKMapTypeStandard];
    [_mapView setZoomEnabled:YES];
    [_mapView setScrollEnabled:YES];
    _labelDestination.hidden = YES;
    _directionsScrollView.contentSize = [DirectionView size];
    _directionsScrollView.scrollEnabled = YES;
    _directionsScrollView.pagingEnabled = YES;
    _directionsScrollView.showsHorizontalScrollIndicator = NO;
    _directionsScrollView.hidden = YES;
    
    // search bar scrollview
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width; // account for different-size screens
    _sourceSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44)];
    _sourceSearchBar.placeholder = @"Your location";
    _sourceSearchBar.delegate = self;
    _sourceSearchBar.tag = 1;
    
    _destinationSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, screenWidth, 44)];
    _destinationSearchBar.placeholder = @"Destination";
    _destinationSearchBar.delegate = self;
    _destinationSearchBar.tag = 2;
    
    UISwipeGestureRecognizer *searchScrollViewShowSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(searchScrollViewSwipeShow)];
    searchScrollViewShowSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    UISwipeGestureRecognizer *searchScrollViewHideSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(searchScrollViewSwipeHide)];
    searchScrollViewHideSwipe.direction = UISwipeGestureRecognizerDirectionUp;
    
    _searchScrollView.pagingEnabled = NO;
    _searchScrollView.scrollEnabled = NO;
    _searchScrollView.bounces = YES;
    _searchScrollView.contentSize = CGSizeMake(375, 44);
    [_searchScrollView setContentOffset:CGPointMake(0, 44) animated:NO]; // start by showing only Destination bar
    [_searchScrollView addSubview:_sourceSearchBar];
    [_searchScrollView addSubview:_destinationSearchBar];
    [_searchScrollView addGestureRecognizer:searchScrollViewShowSwipe];
    [_searchScrollView addGestureRecognizer:searchScrollViewHideSwipe];
    [_searchScrollView setTranslatesAutoresizingMaskIntoConstraints:YES];
    
    // reset pins for source and destination
    destFromPin = kCLLocationCoordinate2DInvalid;
    srcFromPin = kCLLocationCoordinate2DInvalid;
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    [self centerMapOnLocation];
    
    // bounce scroll view after certain time
    searchbarBounceTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(bounceSearchbars)
                                   userInfo:nil
                                    repeats:YES];
}
- (void)searchScrollViewSwipeShow {
    // only bounce until user swipes to reveal both searchbars
    [searchbarBounceTimer invalidate];
    searchbarBounceTimer = nil;
    // expand searchbar scroll view
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        _searchScrollView.frame = CGRectMake(0, 0, 375, 88);
        [UIView commitAnimations];
    });
}
- (void)searchScrollViewSwipeHide {
    // shrink searchbar scroll view
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        _searchScrollView.frame = CGRectMake(0, 0, 375, 44);
        [UIView commitAnimations];
        
        // reset to show destination search bar
        [_searchScrollView setContentOffset:CGPointMake(0, 44)animated:YES];
    });
}

-(void)bounceSearchbars {
    [_searchScrollView setContentOffset:CGPointMake(0, 30) animated:YES];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(unbounceSearchbars) userInfo:nil repeats:NO];
}
-(void)unbounceSearchbars {
    [_searchScrollView setContentOffset:CGPointMake(0, 44) animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollView delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

#pragma mark - PennUber API

- (void)queryHandler:(CLLocationCoordinate2D)start destination:(CLLocationCoordinate2D)end {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *fromAPI;
        @try {
            fromAPI = [self queryAPI:start destination:end];
        } @catch (NSException *e) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Route Found" message:@"We couldn't find a route for you using Penn Transit services." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [alert show];
            });
            return;
        }
        [self parseData:fromAPI trueStart:start trueEnd:end];
    });
}
-(NSDictionary *)queryAPI:(CLLocationCoordinate2D)start destination:(CLLocationCoordinate2D)end
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@latFrom=%f&latTo=%f&lonFrom=%f&lonTo=%f", SERVER_ROOT, TRANSIT_PATH, start.latitude, end.latitude, start.longitude, end.longitude ]];
    /* No Longer in use
    if (!stopMap) {
        NSURL *routesURL = [NSURL URLWithString:[SERVER_ROOT stringByAppendingString:ROUTES_PATH]];
        NSData *routesResult = [NSData dataWithContentsOfURL:routesURL];
        if (![self confirmConnection:routesResult]) {
            return nil;
        }
        NSError *error;
        stopMap = [NSJSONSerialization JSONObjectWithData:routesResult options:NSJSONReadingMutableLeaves error:&error][@"result_data"];
        if (error.code != 0) {
            return nil;
        }
    }
     */
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
    if (error || returned[@"Error"]) {
        [NSException raise:@"JSON parse error" format:@"%@", error];
    }
    return returned[@"result_data"];
}

- (BOOL)confirmConnection:(NSData *)data {
    if (!data) {
        UIAlertView *new = [[UIAlertView alloc] initWithTitle:@"Couldn't Connect to API" message:@"We couldn't connect to Penn's API. Please try again later. :(" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [new show];
        return false;
    }
    return true;
}

LocationArray LocationArrayMake(CLLocationCoordinate2D *arr, int size) {
    LocationArray array;
    array.coords = arr;
    array.size = size;
    return array;
}

// could throw exception if route names don't match
// NOTE : UNUSED
- (LocationArray)gatherRoutePoints:(NSString *)route from:(long)from to:(long)to {
    NSArray *stops = [((NSArray *)stopMap[route]) subarrayWithRange:NSMakeRange(from, to)];
    CLLocationCoordinate2D *arr = malloc(stops.count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < stops.count; i++) {
        arr[i] = CLLocationCoordinate2DMake([stops[i][@"latitude"] doubleValue], [stops[i][@"longitude"] doubleValue]);
    }
    return LocationArrayMake(arr, (int)stops.count);
}

// now used instead
- (LocationArray)gatherRoutePoints:(NSArray *)stops {
    CLLocationCoordinate2D *arr = malloc(stops.count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < stops.count; i++) { 
        arr[i] = CLLocationCoordinate2DMake([stops[i][@"Latitude"] doubleValue], [stops[i][@"Longitude"] doubleValue]);
    }
    return LocationArrayMake(arr, (int)stops.count);
}

- (NSArray *)getStopAnnotations:(NSArray *)path {
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:path.count];
    for (NSDictionary *stop in path) {
        if (stop[@"BusStopName"]) {
            MKPointAnnotation *pt = [[MKPointAnnotation alloc] init];
            pt.coordinate = CLLocationCoordinate2DMake([stop[@"Latitude"] doubleValue], [stop[@"Longitude"] doubleValue]);
            pt.title = [@"Stop " stringByAppendingString:stop[@"BusStopName"]];
            [annotations addObject:pt];
        }
    }
    return annotations;
}

- (void)parseData:(NSDictionary *)fromAPI trueStart:(CLLocationCoordinate2D)trueStart trueEnd:(CLLocationCoordinate2D)trueEnd {
    CLLocationCoordinate2D end, from;
    double endLat, endLon, fromLat, fromLon;
    NSArray *path;
    @try {
        path = fromAPI[@"path"];
        fromLat = [path[0][@"Latitude"] doubleValue];
        fromLon = [path[0][@"Longitude"] doubleValue];
        endLat = [path[path.count - 1][@"Latitude"] doubleValue];
        endLon = [path[path.count - 1][@"Longitude"] doubleValue];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Routing Unavailable." message:@"There was a problem routing to your destination. Please try again. Error: Invalid coordinates from Labs API." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        return;
    }
    end = CLLocationCoordinate2DMake(endLat, endLon);
    from = CLLocationCoordinate2DMake(fromLat, fromLon);
    @try {
        // change this with Hong's code
        LocationArray walkToRoute = [self calculateRoutesFrom:trueStart to:from];
        LocationArray walkFromRoute = [self calculateRoutesFrom:end to:trueEnd];
        LocationArray busRoute = [self gatherRoutePoints:path];
        NSArray *stopAnnotations = [self getStopAnnotations:path];
        if (walkToRoute.size > 0) {
            busRoute.coords[0] = walkToRoute.coords[walkToRoute.size - 1];
        }
        if (walkFromRoute.size > 0) {
            busRoute.coords[busRoute.size -1] = walkFromRoute.coords[0];
        }
        MKPolyline *busLine = [MKPolyline polylineWithCoordinates:busRoute.coords count:busRoute.size];
        busLine.title = @"bus";
        busView = [[MKPolylineRenderer alloc] initWithPolyline:busLine];
        busView.strokeColor = [BUS_COLOR colorWithAlphaComponent:0.7];
        busView.lineWidth = LINE_WEIGHT;
        MKPolyline *walkTo = [MKPolyline polylineWithCoordinates:walkToRoute.coords count:walkToRoute.size];
        walkTo.title = @"walkTo";
        walkToView = [[MKPolylineRenderer alloc] initWithPolyline:walkTo];
        walkToView.strokeColor = [WALK_COLOR colorWithAlphaComponent:0.7];
        walkToView.lineWidth = LINE_WEIGHT;
        MKPolyline *walkFrom = [MKPolyline polylineWithCoordinates:walkFromRoute.coords count:walkFromRoute.size];
        walkFrom.title = @"walkFrom";
        walkFromView = [[MKPolylineRenderer alloc] initWithPolyline:walkFrom];
        walkFromView.strokeColor = [WALK_COLOR colorWithAlphaComponent:0.7];
        walkFromView.lineWidth = LINE_WEIGHT;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapView addOverlay:busLine];
            [_mapView addOverlay:walkFrom];
            [_mapView addOverlay:walkTo];
            [_mapView addAnnotations:stopAnnotations];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self displayRouteUI:fromAPI];
        });
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Routing Unavailable." message:@"There was a problem routing to your destination. Please try again. Error: Invalid route from Google Maps API." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
        return;
    }
}

- (void)displayRouteUI:(NSDictionary *)fromAPI {
    NSString *destTitle;
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        MKAnnotationView* view = [_mapView viewForAnnotation:annotation];
        TransitMKPointAnnotation *pointAnnotation = (TransitMKPointAnnotation *)view.annotation;
        if (![annotation isKindOfClass:[MKUserLocation class]] && [pointAnnotation isDest]) {
            destTitle = pointAnnotation.title;
            break;
        }
    }
    
    NSNumber *endd  = fromAPI[@"walkingDistanceAfter"];
    NSNumber *startd  = fromAPI[@"walkingDistanceBefore"];
    
    double walkStart = [startd doubleValue];
    double walkEnd = [endd doubleValue];
    NSArray *path = fromAPI[@"path"];
    NSString *routeTitle = fromAPI[@"route_name"];
    NSString *fromStop = path[0][@"BusStopName"];
    NSString *toStop = path[path.count - 1][@"BusStopName"];

    DirectionView *first = [DirectionView make:fromStop distance:walkStart routeTitle:nil isLast:NO];
    DirectionView *bus = [DirectionView make:toStop distance:0 routeTitle:routeTitle isLast:NO];
    DirectionView *last = [DirectionView make:destTitle distance:walkEnd routeTitle:nil isLast:YES];
    
    [_directionsScrollView addSubview:first];
    [_directionsScrollView addSubview:bus];
    [_directionsScrollView addSubview:last];
    [_directionsScrollView setContentOffset:CGPointZero animated:NO];
    _labelDestination.text = destTitle;
    _labelDestination.hidden = NO;
    _directionsScrollView.hidden = NO;
    [_directionsScrollView setContentOffset:CGPointMake(15, 0) animated:YES];
    
}
- (void)hideRouteUI {
    _directionsScrollView.hidden = YES;
    _labelDestination.hidden = YES;
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlays:_mapView.overlays];
}

#pragma mark - Google Maps Polyline Finder

-(LocationArray) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&mode=walking", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    NSLog(@"api url: %@", apiUrl);
    NSError *error;
    NSData *apiResponse = [NSData dataWithContentsOfURL:apiUrl options:NSDataReadingUncached error:&error];
    if (error) {
        [NSException raise:@"Error in point parsing." format:@""];
    }
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"points:\\\"([^\\\"]*)\\\"" options:0 error:NULL];
//    NSTextCheckingResult *match = [regex firstMatchInString:apiResponse options:0 range:NSMakeRange(0, [apiResponse length])];
//    NSString *encodedPoints = [apiResponse substringWithRange:[match rangeAtIndex:1]];
    return [self decodePolyLine:[apiResponse mutableCopy]];
}

// http://stackoverflow.com/questions/31090531/did-google-maps-api-just-retire-the-dragdir-parameter
-(LocationArray)decodePolyLine:(NSData *)encoded {
//    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
//                                options:NSLiteralSearch
//                                  range:NSMakeRange(0, [encoded length])];
//    NSInteger len = [encoded length];
//    NSInteger index = 0;
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    NSInteger lat=0;
//    NSInteger lng=0;
//    while (index < len) {
//        NSInteger b;
//        NSInteger shift = 0;
//        NSInteger result = 0;
//        do {
//            b = [encoded characterAtIndex:index++] - 63;
//            result |= (b & 0x1f) << shift;
//            shift += 5;
//        } while (b >= 0x20);
//        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
//        lat += dlat;
//        shift = 0;
//        result = 0;
//        do {
//            b = [encoded characterAtIndex:index++] - 63;
//            result |= (b & 0x1f) << shift;
//            shift += 5;
//        } while (b >= 0x20);
//        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
//        lng += dlng;
//        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
//        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
//        // printf("[%f,", [latitude doubleValue]);
//        // printf("%f]", [longitude doubleValue]);
//        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
//        [array addObject:loc];
//    }
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:encoded options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        [NSException raise:@"Error in point parsing." format:@""];
    }
    @try {
        json = json[@"routes"][0][@"legs"][0];
    }
    @catch (NSException *exception) {
        [NSException raise:@"Error in point parsing." format:@""];
    }
    NSArray *steps = json[@"steps"];
    
    /** we need to get this into a fucking C array. So stupid
     * So, because in the previous for loop we don't know the end size of the array
     * beforehand, we must only convert to c array after the fact. 
     **/
    CLLocationCoordinate2D *arr = malloc(sizeof(CLLocationCoordinate2D) * (steps.count + 1));
    CLLocationCoordinate2D start = CLLocationCoordinate2DMake([json[@"start_location"][@"lat"] floatValue], [json[@"start_location"][@"lng"] floatValue]);
    arr[0] = start;
    for (int i = 0; i < steps.count; i++) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([steps[i][@"end_location"][@"lat"] floatValue], [steps[i][@"end_location"][@"lng"] floatValue]);
        arr[i+1] = coord;
    }
    LocationArray returned = LocationArrayMake(arr, steps.count + 1);
    return returned;
}

#pragma mark - Searching and Plotting

- (void)plotResults {
    [_mapView removeAnnotations:_mapView.annotations];
    TransitMKPointAnnotation *temp;
    if (results.count > 0) {
        for (long i = results.count - 1; i >= 0; i--) {
            temp = [[TransitMKPointAnnotation alloc] init];
            temp.coordinate = ((MKMapItem *) results[i]).placemark.coordinate;
            temp.title = ((MKMapItem *) results[i]).name;
            // these values were originally store in a local hashmap but wasn't worth it
            [_mapView addAnnotation:temp];
        }
        [_mapView selectAnnotation:temp animated:YES];
    }
    
}

- (void)addGoogleAnnotations:(NSArray *)res isDest:(BOOL)isDest {
    TransitMKPointAnnotation *temp;
    if (res.count > 0) {
        for (long i = res.count - 1; i >= 0; i--) {
            temp = (TransitMKPointAnnotation *)[GoogleMapsSearcher makeAnnotationForGoogleResult:res[0]];
            temp.isDest = isDest;
            // these values were originally store in a local hashmap but wasn't worth it
            [_mapView addAnnotation:temp];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [_mapView showAnnotations:_mapView.annotations animated:YES];
        [_mapView selectAnnotation:temp animated:YES];
    }
}

/**
 * The majority of this code is from Apple's samples. Just a heads up
 **/
- (void)searchFrom:(NSString *)source to:(NSString *)dest {
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = locationManager.location.coordinate.latitude; // TODO: change this based on start?
    newRegion.center.longitude = locationManager.location.coordinate.longitude;
    
    // setup the area spanned by the map region:
    // we use the delta values to indicate the desired zoom level of the map,
    //      (smaller delta values corresponding to a higher zoom level)
    //
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    // get results for destination pin
    NSArray *res = [GoogleMapsSearcher getResultsFrom:[GoogleMapsSearcher generateURLRequest:_mapView.region.center withRadius:SEARCH_RADIUS andKeyword:dest]];
    if (res.count > 0 && [((NSString *)res[0][@"name"]) rangeOfString:API_ERROR_DELIM].location != NSNotFound) {
        // there was an error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Google Maps API Error"
                                                        message:res[0]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    } else if (res.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find any results"
                                                        message:@"Please try a different query."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    else {
//        [self addGoogleAnnotations:res];
        [self addGoogleAnnotations:res isDest:YES];
        // used for later when setting the map's region in "prepareForSegue"
        // _boundingRegion = response.boundingRegion;
    }
    [_destinationSearchBar resignFirstResponder];
    
    // now get results for source pin
    if (source.length > 0) {
        res = [GoogleMapsSearcher getResultsFrom:[GoogleMapsSearcher generateURLRequest:_mapView.region.center withRadius:SEARCH_RADIUS andKeyword:source]];
        if (res.count > 0 && [((NSString *)res[0][@"name"]) rangeOfString:API_ERROR_DELIM].location != NSNotFound) {
            // there was an error
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Google Maps API Error"
                                                            message:res[0]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        } else if (res.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find any results"
                                                            message:@"Please try a different query."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        else {
//            [self addGoogleAnnotations:res];
            [self addGoogleAnnotations:res isDest:NO];
            // used for later when setting the map's region in "prepareForSegue"
            // _boundingRegion = response.boundingRegion;
        }
        [_sourceSearchBar resignFirstResponder];
    }
}

#pragma mark - Bus Stops Display

- (IBAction)stopsButtonPressed:(id)sender {
    
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation.title isEqualToString:@"Current Location"]) {
        return nil; // use default blue dot
    }
    
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotation.title];
    if ([annotation.title rangeOfString:@"Stop "].location != NSNotFound) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation.title substringFromIndex:5]];
        annotationView.image = [UIImage imageNamed:@"BusStopPin"];
        annotationView.canShowCallout = YES;
        return annotationView;
    }
    
    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.title];
    
    if ([(TransitMKPointAnnotation *)annotation isDest]) {
        pinView.enabled = YES;
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        pinView.pinColor = MKPinAnnotationColorRed;
        return pinView;
    } else {
        pinView.enabled = YES;
        pinView.canShowCallout = YES;
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeContactAdd];
        pinView.pinColor = MKPinAnnotationColorGreen;
        return pinView;
    }
    return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolyline *pl = overlay;
    for (int i = 0; i < pl.pointCount; i++) {
        MKMapPoint pt = pl.points[i];
        NSLog(@"%f %f", pt.x, pt.y);
    }
    if ([overlay.title isEqualToString:@"bus"]) {
        return busView;
    } else if ([overlay.title isEqualToString:@"walkFrom"]) {
        return walkFromView;
    } else if ([overlay.title isEqualToString:@"walkTo"]) {
        return walkToView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    TransitMKPointAnnotation *annotation = (TransitMKPointAnnotation *)view.annotation;
    if ([annotation isDest]) { // destination pin
        destFromPin = view.annotation.coordinate;
    }
    if ([_sourceSearchBar text].length <= 0) { // default to user location
        srcFromPin = locationManager.location.coordinate;
    } else if (![annotation isDest]) {
        srcFromPin = view.annotation.coordinate;
    }
//    [self mapView:mapView clearAllPinsExcept:view.annotation];
    
    if (!CLLocationCoordinate2DIsValid(destFromPin)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Route Found" message:@"Please make sure to set a destination." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [alert show];
        });
        return;
    }
    [self queryHandler:srcFromPin destination:destFromPin];
}

- (void)mapView:(MKMapView *)mapView clearAllPinsExcept:(id<MKAnnotation>)annot {
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]] && ![annotation isEqual:annot]) {
            [mapView removeAnnotation:annotation];
        }
    }
}

- (void)mapViewClearAllPinsNotUser:(MKMapView *)mapView {
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            [mapView removeAnnotation:annotation];
        }
    }
    [_mapView removeOverlays:_mapView.overlays];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self mapViewClearAllPinsNotUser:_mapView];
    [self hideRouteUI];
//    [self search:searchBar.text];
    [self searchFrom:[_sourceSearchBar text] to:[_destinationSearchBar text]];
    if ([_sourceSearchBar text].length == 0) {
        // collapse search bars, only show destination
        [self searchScrollViewSwipeHide];
    }
    shouldCenter = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self hideRouteUI];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0) {
        [self mapViewClearAllPinsNotUser:_mapView];
        [self hideRouteUI];
        // reset src and dest
        if (searchBar.tag == 2) { // destinationSearchBar
            destFromPin = kCLLocationCoordinate2DInvalid;
        } else if (searchBar.tag == 1) { // sourceSearchBar
            srcFromPin = kCLLocationCoordinate2DInvalid;
        }
    }
}

#pragma mark - CLLocationManager

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (shouldCenter) {
        [self centerMapOnLocation];
        shouldCenter = NO;
    }
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManager startUpdatingLocation];
        self.mapView.showsUserLocation = YES;
        shouldCenter = YES;
    }
}

- (void)centerMapOnLocation {
    //View Area
    MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = locationManager.location.coordinate.latitude;
    region.center.longitude = locationManager.location.coordinate.longitude;
    region.span.longitudeDelta = 0.005f;
    region.span.longitudeDelta = 0.005f;
    [_mapView setRegion:region animated:YES];
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
        [[SlideOutMenuViewController instance] performSegueWithIdentifier:@"Transit" sender:self];
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
            // ((UIGestureRecognizer *) view.gestureRecognizers[0]).enabled = NO;
        }
        float width = [[UIScreen mainScreen] bounds].size.width;
        float height = [[UIScreen mainScreen] bounds].size.height;
        UIView *grayCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [grayCover setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        [grayCover addGestureRecognizer:cancelTouches];
        
        UISwipeGestureRecognizer *swipeToCancel = [[UISwipeGestureRecognizer alloc] initWithTarget:menu action:@selector(returnToView:)];
        swipeToCancel.direction = UISwipeGestureRecognizerDirectionLeft;
        [grayCover addGestureRecognizer:swipeToCancel];
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
}


@end
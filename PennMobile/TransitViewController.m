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
    _scrollView.contentSize = [DirectionView size];
    _scrollView.scrollEnabled = YES;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.hidden = YES;
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated {
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    shouldCenter = YES;
    [locationManager startUpdatingLocation];
    [self centerMapOnLocation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - PennUber API

- (void)queryHandler:(CLLocationCoordinate2D)start destination:(CLLocationCoordinate2D)end {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSDictionary *fromAPI;
        @try {
            fromAPI = [self queryAPI:locationManager.location.coordinate destination:end];
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
    return LocationArrayMake(arr, stops.count);
}

// now used instead
- (LocationArray)gatherRoutePoints:(NSArray *)stops {
    CLLocationCoordinate2D *arr = malloc(stops.count * sizeof(CLLocationCoordinate2D));
    for (int i = 0; i < stops.count; i++) {
        arr[i] = CLLocationCoordinate2DMake([stops[i][@"Latitude"] doubleValue], [stops[i][@"Longitude"] doubleValue]);
    }
    return LocationArrayMake(arr, stops.count);
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
        LocationArray busRoute = [self gatherRoutePoints:path];
        MKPolyline *busLine = [MKPolyline polylineWithCoordinates:busRoute.coords count:busRoute.size];
        busLine.title = @"bus";
        busView = [[MKPolylineRenderer alloc] initWithPolyline:busLine];
        busView.strokeColor = [BUS_COLOR colorWithAlphaComponent:0.7];
        busView.lineWidth = LINE_WEIGHT;
        LocationArray walkToRoute = [self calculateRoutesFrom:trueStart to:from];
        LocationArray walkFromRoute = [self calculateRoutesFrom:end to:trueEnd];
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
    NSString *destTitle = ((id<MKAnnotation>)_mapView.selectedAnnotations[0]).title;
    
    NSNumber *endd  = fromAPI[@"walkingDistanceAfter"];
    NSNumber *startd  = fromAPI[@"walkingDistanceBefore"];
    
    double walkStart = [startd doubleValue];
    double walkEnd = [endd doubleValue];
    NSArray *path = fromAPI[@"path"];
    NSString *routeTitle = fromAPI[@"route"];
    NSString *fromStop = path[0][@"BusStopName"];
    NSString *toStop = path[path.count - 1][@"BusStopName"];

    DirectionView *first = [DirectionView make:fromStop distance:walkStart isBus:NO isLast:NO];
    DirectionView *bus = [DirectionView make:toStop distance:0 isBus:YES isLast:NO];
    DirectionView *last = [DirectionView make:destTitle distance:walkEnd isBus:NO isLast:YES];
    
    [_scrollView addSubview:first];
    [_scrollView addSubview:bus];
    [_scrollView addSubview:last];
    [_scrollView setContentOffset:CGPointZero animated:NO];
    _labelDestination.text = destTitle;
    _labelDestination.hidden = NO;
    _scrollView.hidden = NO;
    
}
- (void)hideRouteUI {
    _scrollView.hidden = YES;
    _labelDestination.hidden = YES;
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlays:_mapView.overlays];
}

#pragma mark - Google Maps Polyline Finder

// taken from https://github.com/kadirpekel/MapWithRoutes/blob/master/Classes/MapView.m
// LOL
-(LocationArray) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@&mode=walking", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    NSLog(@"api url: %@", apiUrl);
    NSError *error;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [NSException raise:@"Error in point parsing." format:@""];
    }
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"points:\\\"([^\\\"]*)\\\"" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:apiResponse options:0 range:NSMakeRange(0, [apiResponse length])];
    NSString *encodedPoints = [apiResponse substringWithRange:[match rangeAtIndex:1]];
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

// taken from https://github.com/kadirpekel/MapWithRoutes/blob/master/Classes/MapView.m
// LOL
-(LocationArray)decodePolyLine:(NSMutableString *)encoded {
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        // printf("[%f,", [latitude doubleValue]);
        // printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    /** we need to get this into a fucking C array. So stupid
     * So, because in the previous for loop we don't know the end size of the array
     * beforehand, we must only convert to c array after the fact. 
     **/
    CLLocationCoordinate2D *arr = malloc(sizeof(CLLocationCoordinate2D) * array.count);
    for (int i = 0; i < array.count; i++) {
        arr[i] = ((CLLocation *) [array objectAtIndex:i]).coordinate;
    }
    LocationArray returned = LocationArrayMake(arr, array.count);
    return returned;
}

#pragma mark - Searching and Plotting

- (void)plotResults {
    [_mapView removeAnnotations:_mapView.annotations];
    MKPointAnnotation *temp;
    if (results.count > 0) {
        for (long i = results.count - 1; i >= 0; i--) {
            temp = [[MKPointAnnotation alloc] init];
            temp.coordinate = ((MKMapItem *) results[i]).placemark.coordinate;
            temp.title = ((MKMapItem *) results[i]).name;
            // these values were originally store in a local hashmap but wasn't worth it
            [_mapView addAnnotation:temp];
        }
        [_mapView selectAnnotation:temp animated:YES];
    }
    
}

- (void)addGoogleAnnotations:(NSArray *)res {
    MKPointAnnotation *temp;
    if (res.count > 0) {
        for (long i = res.count - 1; i >= 0; i--) {
            temp = [GoogleMapsSearcher makeAnnotationForGoogleResult:res[0]];
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
- (void)search:(NSString *)query {
    MKCoordinateRegion newRegion;
    newRegion.center.latitude = locationManager.location.coordinate.latitude;
    newRegion.center.longitude = locationManager.location.coordinate.longitude;
    
    // setup the area spanned by the map region:
    // we use the delta values to indicate the desired zoom level of the map,
    //      (smaller delta values corresponding to a higher zoom level)
    //
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;

    
    /* OLD
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = query;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error) {
        if (error != nil) {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find any results."
                                                            message:errorStr
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else {
            results = [response mapItems];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self plotResults];
            // used for later when setting the map's region in "prepareForSegue"
            _boundingRegion = response.boundingRegion;
        }
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:completionHandler];
     * --- END OLD ---- */
    NSArray *res = [GoogleMapsSearcher getResultsFrom:[GoogleMapsSearcher generateURLRequest:_mapView.region.center withRadius:SEARCH_RADIUS andKeyword:query]];
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
        [self addGoogleAnnotations:res];
        // used for later when setting the map's region in "prepareForSegue"
       // _boundingRegion = response.boundingRegion;
    }
    [_searchBar resignFirstResponder];
}

#pragma mark - Bus Stops Display

- (IBAction)stopsButtonPressed:(id)sender {
    
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotation.title];
    if (!annotationView && ![annotation isKindOfClass:[MKUserLocation class] ]) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.title];
    }
    if ([annotationView isKindOfClass:[MKPinAnnotationView class]]) {
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        return annotationView;
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
    CLLocationCoordinate2D dest = view.annotation.coordinate;
    [self mapView:mapView clearAllPinsExcept:view.annotation];
    [self queryHandler:locationManager.location.coordinate destination:dest];
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
    [self search:searchBar.text];
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
    }
}
#pragma mark - CLLocationManager

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (shouldCenter) {
        //[self centerMapOnLocation];
    }
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
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
//
//  TransitViewController.h
//  PennMobile
//
//  Created by Sacha Best on 9/30/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideOutMenuViewController.h"
#import <MapKit/MapKit.h>

#define TRANSIT_PATH @'transit/routing?'
// latFrom latTO lonFrom lonTo
//

@interface TransitViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate> {
    UITapGestureRecognizer *cancelTouches;
    CLLocationManager *locationManager;
    NSArray *results;
    BOOL shouldCenter;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

- (void)search:(NSString *)query;
- (BOOL)confirmConnection:(NSData *)data;

@end

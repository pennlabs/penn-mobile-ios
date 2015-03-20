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

#define TRANSIT_PATH @"transit/routing?"
// latFrom latTO lonFrom lonTo
//

@interface TransitViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate> {
    UITapGestureRecognizer *cancelTouches;
    CLLocationManager *locationManager;
    NSArray *results;
    BOOL shouldCenter;
    MKPolylineRenderer *busView;
    MKPolylineRenderer *walkToView;
    MKPolylineRenderer *walkFromView;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *labelDestination;
@property (weak, nonatomic) IBOutlet UILabel *labelRouteName;
@property (weak, nonatomic) IBOutlet UILabel *labelEnd;
@property (weak, nonatomic) IBOutlet UILabel *labelStart;
@property (weak, nonatomic) IBOutlet UILabel *labelWalkEnd;
@property (weak, nonatomic) IBOutlet UILabel *labelWalkStart;

@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

- (void)search:(NSString *)query;
- (BOOL)confirmConnection:(NSData *)data;

@end

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
#import "DirectionView.h"
#import "GoogleMapsSearcher.h"

#define TRANSIT_PATH @"transit/routing?"
#define BUS_COLOR [UIColor blueColor]
#define WALK_COLOR [UIColor redColor]
#define LINE_WEIGHT 5.0
#define REGION_MARGIN 2.0f

@interface TransitViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate> {
    UITapGestureRecognizer *cancelTouches;
    CLLocationManager *locationManager;
    NSArray *results;
    BOOL shouldCenter;
    MKPolylineRenderer *busView;
    MKPolylineRenderer *walkToView;
    MKPolylineRenderer *walkFromView;
}

typedef struct LocationArray {
    CLLocationCoordinate2D *coords;
    int size;
} LocationArray;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *labelDestination;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

- (void)search:(NSString *)query;
- (BOOL)confirmConnection:(NSData *)data;

@end

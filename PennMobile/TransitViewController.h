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
#define ROUTES_PATH @"transit/routes/"

@interface TransitViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, CLLocationManagerDelegate> {
    UITapGestureRecognizer *cancelTouches;
    CLLocationManager *locationManager;
    NSArray *results;
    BOOL shouldCenter;
    MKPolylineRenderer *busView;
    MKPolylineRenderer *walkToView;
    MKPolylineRenderer *walkFromView;
    NSDictionary *stopMap;
    NSTimer *searchbarBounceTimer;
}

typedef struct LocationArray {
    CLLocationCoordinate2D *coords;
    int size;
} LocationArray;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UISearchBar *destinationSearchBar; // tag = 2
@property (nonatomic, strong) UISearchBar *sourceSearchBar; // tag = 1
@property (weak, nonatomic) IBOutlet UILabel *labelDestination;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopsButton;
@property (weak, nonatomic) IBOutlet UIScrollView *directionsScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *searchScrollView; // tag = 3


@property (nonatomic, assign) MKCoordinateRegion boundingRegion;

- (void)search:(NSString *)query;
- (BOOL)confirmConnection:(NSData *)data;

@end

//
//  BuildingViewController.h
//  PennMobile
//
//  Created by Sacha Best on 2/12/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DetailViewController.h"
#import "Building.h"
#import "SlideOutMenuViewController.h"

#define BUILDING_PATH @"buildings/search?q="

@interface BuildingViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate> {
    bool hasCentered;
    Building *selected;
    NSMutableArray *results;
    NSMutableDictionary *resultToName;
    UITapGestureRecognizer *cancelTouches;
    bool pinSelected;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property(nonatomic, retain) CLLocationManager *locationManager;

@end

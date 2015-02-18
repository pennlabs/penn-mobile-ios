//
//  Building.h
//  PennMobile
//
//  Created by Sacha Best on 2/17/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Building : NSObject

@property NSArray *images;
@property NSString *name;
@property NSString *code;
@property NSString *addressStreet;
@property NSString *addressCity;
@property NSString *addressState;
@property NSString *yearBuilt;
@property NSURL *link;

@property NSString *zip;
@property NSString *desc;
@property CLLocationCoordinate2D coord;
@property MKPointAnnotation *mapPoint;

- (NSString *)generateFullAddress;
- (bool)hasImage;
- (void)setCoordAndGenerate:(CLLocationCoordinate2D)coord;

@end

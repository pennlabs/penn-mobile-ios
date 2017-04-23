//
//  GoogleMapsSearcher.h
//  PennMobile
//
//  Created by Sacha Best on 3/31/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define SEARCH_RADIUS 5000
#define API_ERROR_DELIM @"Google API"

@interface GoogleMapsSearcher : NSObject

+ (NSURL *)generateURLRequest:(CLLocationCoordinate2D)center withRadius:(double)radius andKeyword:(NSString *)keyword;

+ (NSArray *)getResultsFrom:(NSURL *)req;

+ (MKPointAnnotation *)makeAnnotationForGoogleResult:(NSDictionary *)res;

@end

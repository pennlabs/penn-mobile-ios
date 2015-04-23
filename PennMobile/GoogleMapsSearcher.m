
//
//  GoogleMapsSearcher.m
//  PennMobile
//
//  Created by Sacha Best on 3/31/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "GoogleMapsSearcher.h"
#import "TransitMKPointAnnotation.h"

@implementation GoogleMapsSearcher

+ (NSURL *)generateURLRequest:(CLLocationCoordinate2D)center withRadius:(double)radius andKeyword:(NSString *)keyword {
    NSString *baseURL = [@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=" stringByAppendingFormat:@"%@&", GOOGLE_SECRET];
    NSString *fullURL = [baseURL stringByAppendingFormat:@"location=%f,%f&radius=%d&keyword=%@", center.latitude, center.longitude, (int) radius, [keyword stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [NSURL URLWithString:fullURL];
}

+ (NSArray *)getResultsFrom:(NSURL *)req {
    @try {
        NSData *data = [NSData dataWithContentsOfURL:req];
        NSError *error;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
        if (error && error.code != 0) {
            [NSException raise:@"JSON Parse Error." format:@"Google API JSON Parse Error."];
        }
        if (res.count > 0) {
            if ([res[@"status"] isEqualToString:@"ZERO_RESULTS"]) {
                return @[];
            } else if (![res[@"status"] isEqualToString:@"OK"]) {
                return @[[NSString stringWithFormat:@"Google Maps API returned %@", res[@"status"]]];
            }
        }
        if ([res[@"results"] isKindOfClass:[NSDictionary class]]) {
            return @[res[@"results"]];
        }
        return res[@"results"];
    }
    @catch (NSException *exception) {
        return @[exception.reason];
    }
}

/*
+ (MKPointAnnotation *)makeAnnotationForGoogleResult:(NSDictionary *)res {
    MKPointAnnotation *new = [[MKPointAnnotation alloc] init];
    new.title = res[@"name"];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([res[@"geometry"][@"location"][@"lat"] doubleValue], [res[@"geometry"][@"location"][@"lng"] doubleValue]);
    new.coordinate = coord;
    // way more content to use here if we want to...
    return new;
}
 */

+ (TransitMKPointAnnotation *)makeAnnotationForGoogleResult:(NSDictionary *)res {
    TransitMKPointAnnotation *new = [[TransitMKPointAnnotation alloc] init];
    new.title = res[@"name"];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([res[@"geometry"][@"location"][@"lat"] doubleValue], [res[@"geometry"][@"location"][@"lng"] doubleValue]);
    new.coordinate = coord;
    // way more content to use here if we want to...
    return new;
}
@end

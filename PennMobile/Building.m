//
//  Building.m
//  PennMobile
//
//  Created by Sacha Best on 2/17/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "Building.h"

@implementation Building

- (NSString *)generateFullAddress {
    if (self.addressState && self.addressStreet && self.addressCity) {
        return [NSString stringWithFormat:@"%@, %@, %@ %@", self.addressStreet, self.addressCity, self.addressState, self.zip];
    }
    return nil;
}
- (bool)hasImage {
    return self.images.count > 0;
}
// CALL THIS AFTER MAKING TITLE
- (void)setCoordAndGenerate:(CLLocationCoordinate2D)coord {
    self.coord = coord;
    MKPointAnnotation *pt = [[MKPointAnnotation alloc] init];
    if (self.name)
        pt.title = self.name;
    pt.coordinate = coord;
    self.mapPoint = pt;
}
@end

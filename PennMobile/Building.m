//
//  Building.m
//  PennMobile
//
//  Created by Sacha Best on 2/17/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "Building.h"

@implementation Building

- (NSString *)generateFullAddress:(bool)twoline {
    if (self.addressState && self.addressStreet && self.addressCity) {
        NSString *delim = @", ";
        if (twoline) {
            delim = @"\n";
        }
        return [NSString stringWithFormat:@"%@%@%@, %@ %@", self.addressStreet, delim, self.addressCity, self.addressState, self.zip];
    }
    return nil;
}
- (NSDictionary *)createAddressDictionary {
    return @{
             (__bridge NSString *) kABPersonAddressStreetKey : self.addressState,
             (__bridge NSString *) kABPersonAddressCityKey : self.addressCity,
             (__bridge NSString *) kABPersonAddressStateKey : self.addressState,
             (__bridge NSString *) kABPersonAddressZIPKey : self.zip,
             (__bridge NSString *) kABPersonAddressCountryKey : @"United States",
             (__bridge NSString *) kABPersonAddressCountryCodeKey : @"USA"
             };
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
- (void)loadImageWithBlock:(void (^)(UIImage *img))block {
    if ([self hasImage]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            UIImage *res = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_images[0]]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(res);
            });
        });
    } else {
        block(nil);
    }
}

@end

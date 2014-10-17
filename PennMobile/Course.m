//
//  Course.m
//  PennMobile
//
//  Created by Sacha Best on 10/14/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "Course.h"

@implementation Course

// This used to be done by identifier - but for now Title will suffice
-(bool)isEqual:(id)object {
    return [_title isEqualToString:((Course *)object).title];
}

- (NSUInteger)hash {
    return [_title hash];
}

@end

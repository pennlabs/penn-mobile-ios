//
//  Course.m
//  PennMobile
//
//  Created by Sacha Best on 10/14/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "Course.h"

@implementation Course

-(bool)isEqual:(id)object {
    return [_identifier isEqualToString:((Course *)object).identifier];
}

- (NSUInteger)hash {
    return [_identifier hash];
}

@end

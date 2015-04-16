//
//  PCReview.m
//  PennMobile
//
//  Created by Sacha Best on 11/6/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "PCReview.h"

@implementation PCReview

+ (PCReview *)reviewWithCourse:(double)course inst:(double)inst diff:(double)diff {
    PCReview *this = [PCReview init];
    this.course = course;
    this.diff = diff;
    this.inst = inst;
    return this;
}

@end

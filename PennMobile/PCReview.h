//
//  PCReview.h
//  PennMobile
//
//  Created by Sacha Best on 11/6/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCReview : NSObject {
    NSArray *data;
}

+ (id)reviewWithCourse:(double)course inst:(double)inst diff:(double)diff;

@property double diff;
@property double course;
@property double inst;

@end

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

- (id)initWithCourse:(double)course inst:(double)inst diff:(double)diff;

- (double)diff;
- (double)inst;
- (double)course;

@end

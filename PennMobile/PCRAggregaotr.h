//
//  PCRAggregaotr.h
//  PennMobile
//
//  Created by Sacha Best on 11/6/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Course.h"
#import "PCReview.h"

#define SEARCH_URL @"http://api.penncoursereview.com/v1/search?token=%@&q=%@"
#define REVIEW_URL @"http://api.penncoursereview.com/v1/courses/%@/reviews?token=%@"

@interface PCRAggregaotr : NSObject

/**
 *  @brief Given a Course object, this method returns an array of PCRReviews pertaining to that course. These reviews are sorted from most recent to least recent. For a weighted average, call getAverageReviewFor instead.
 *
 *  @param course The Course object to get a review for.
 *
 *  @return An array of PCReview objects.
 */
+ (NSArray *)getReviewsFor:(Course *)course;

/**
 *  @brief  Given a Course object, this method returns the average PCR scores for usage in the Registrar view.
 *
 *  @param course The Course object ot get a review for.
 *
 *  @return A PCReview averaged object.
 */
+ (PCReview *)getAverageReviewFor:(Course *)course;

@end
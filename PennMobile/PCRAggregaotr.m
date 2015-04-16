//
//  PCRAggregaotr.m
//  PennMobile
//
//  Created by Sacha Best on 11/6/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "PCRAggregaotr.h"

@implementation PCRAggregaotr

static NSMutableDictionary *reviews;
static NSMutableDictionary *averages;
/**
 *  @brief Static initializer used to create the reviews hashmap. This map stores data locally to save API calls.
 */
+ (void)initialize {
    if (self == [PCRAggregaotr class]) {
        reviews = [[NSMutableDictionary alloc] init];
        averages = [[NSMutableDictionary alloc] init];

    }
}

+ (PCReview *) getAverageReviewFor:(Course *)course {
    if (!averages[course]) {
        if (!reviews[course]) {
            [PCRAggregaotr getReviewsFor:course];
        }
        double overall, inst, diff;
        for (PCReview *rev in reviews[course]) {
            overall += rev.course;
            inst += rev.inst;
            diff += rev.diff;
        }
        overall /= (double) [reviews[course] count];
        inst /= (double) [reviews[course] count];
        diff /= (double) [reviews[course] count];
        averages[course] = [[PCReview alloc] initWithCourse:overall inst:inst diff:diff];
    }
    return averages[course];
    
}

+ (NSArray *)getReviewsFor:(Course *)course {
    if (!reviews[course]) {
        NSArray *raw = [PCRAggregaotr queryAPI:course.identifier];
        NSMutableArray *revs = [[NSMutableArray alloc] initWithCapacity:raw.count];
        @try {
            for (NSDictionary *json in raw) {
                [revs addObject:[PCRAggregaotr parseReview:json]];
                reviews[course] = revs;
            }
        }
        @catch (NSException *exception) {
            // will throw up a UIAlertView
            [self confirmConnection:nil];
        }
    }
    return reviews[course];
}

+ (PCReview *)parseReview:(NSDictionary *)json {
    double course = [json[@"Course"] doubleValue];
    double inst = [json[@"Instructor"] doubleValue];
    double diff = [json[@"Difficulty"] doubleValue];
    return [[PCReview alloc] initWithCourse:course inst:inst diff:diff];
}

/**
 *  @brief An internal helper used to process URL requests to the PCR API.
 *
 *  @param term the NSString identifier for the Course in question (i.e. YYYYS-DDDD-###)
 *
 *  @return JSON from the PCR API
 */
+ (NSArray *)queryAPI:(NSString *)term {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:REVIEW_URL, term, PCR_TOKEN]];
    NSData *result = [NSData dataWithContentsOfURL:url];
    if (![PCRAggregaotr confirmConnection:result]) {
        return nil;
    }
    NSError *error;
    NSDictionary *returned = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
    if (error || !returned[@"result"]) {
        [NSException raise:@"JSON parse error" format:@"%@", error];
    }
    return returned[@"result"];
}


+ (BOOL)confirmConnection:(NSData *)data {
    if (!data) {
        UIAlertView *new = [[UIAlertView alloc] initWithTitle:@"Couldn't Connect to API" message:@"We couldn't connect to Penn's API. Please try again later. :(" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [new show];
        return false;
    }
    return true;
}
@end

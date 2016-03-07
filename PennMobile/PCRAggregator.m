//
//  PCRAggregaotr.m
//  PennMobile
//
//  Created by Sacha Best on 11/6/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "PCRAggregator.h"

@implementation PCRAggregator

static NSMutableDictionary *reviews;
static NSMutableDictionary *averages;
/**
 *  @brief Static initializer used to create the reviews hashmap. This map stores data locally to save API calls.
 */
+ (void)initialize {
    if (self == [PCRAggregator class]) {
        reviews = [[NSMutableDictionary alloc] init];
        averages = [[NSMutableDictionary alloc] init];

    }
}

+ (PCReview *) getAverageReviewFor:(Course *)course {
    if (!averages[course.identifier]) {
        if (!reviews[course.identifier]) {
            [PCRAggregator getReviewsFor:course];
        }
        double overall, inst, diff;
        for (PCReview *rev in reviews[course.identifier]) {
            overall += rev.course;
            inst += rev.inst;
            diff += rev.diff;
        }
        overall /= (double) [reviews[course.identifier] count];
        inst /= (double) [reviews[course.identifier] count];
        diff /= (double) [reviews[course.identifier] count];
        averages[course.identifier] = [PCReview reviewWithCourse:overall inst:inst diff:diff];
    }
    return averages[course.identifier];
    
}

+ (NSArray *)getReviewsFor:(Course *)course {
    if (!reviews[course.identifier]) {
        NSArray *raw = [PCRAggregator queryAPI:course.identifier][@"values"];
        @try {
            if (raw.count > 0) {
                NSMutableArray *revs = [[NSMutableArray alloc] initWithCapacity:raw.count];
                for (NSDictionary *json in raw) {
                    [revs addObject:[PCRAggregator parseReview:json[@"ratings"]]];
                }
                reviews[course.identifier] = revs;
            }
        }
        @catch (NSException *exception) {
            // will throw up a UIAlertView -not anymore - silent fail
            //[self confirmConnection:nil];
        }
    }
    return reviews[course.identifier];
}

+ (PCReview *)parseReview:(NSDictionary *)json {
    double course = [json[@"rCourseQuality"] doubleValue];
    double inst = [json[@"rInstructorQuality"] doubleValue];
    double diff = [json[@"rDifficulty"] doubleValue];
    return [PCReview reviewWithCourse:course inst:inst diff:diff];
}

/**
 *  @brief An internal helper used to process URL requests to the PCR API.
 *
 *  @param term the NSString identifier for the Course in question (i.e. YYYYS-DDDD-###)
 *
 *  @return JSON from the PCR API
 */
+ (NSDictionary *)queryAPI:(NSString *)term {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:REVIEW_URL, term, PCR_TOKEN]];
    NSData *result = [NSData dataWithContentsOfURL:url];
    if (![PCRAggregator confirmConnection:result]) {
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
//        UIAlertView *new = [[UIAlertView alloc] initWithTitle:@"Couldn't Connect to API" message:@"We couldn't connect to Penn's API. Please try again later. :(" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //changed to silent failure
        //[new show];
        return false;
    }
    return true;
}
@end

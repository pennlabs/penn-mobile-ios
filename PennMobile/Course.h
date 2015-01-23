//
//  Course.h
//  PennMobile
//
//  Created by Sacha Best on 10/14/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface Course : NSObject

@property NSString *dept;
@property NSString *title;
@property NSString *courseNum;
@property NSString *credits;
@property NSString *sectionNum;
@property NSString *type;
@property NSString *times;
@property NSString *building;
@property NSString *buildingCode;
@property NSString *roomBum;
@property NSArray *professors;
@property NSString *desc;
@property NSString *primaryProf;
@property NSString *identifier;
@property MKPointAnnotation *point;
@property NSString *sectionID;

- (NSString *)createDetail;

@end

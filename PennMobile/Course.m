//
//  Course.m
//  PennMobile
//
//  Created by Sacha Best on 10/14/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "Course.h"

@implementation Course

- (id)copyWithZone:(NSZone *)zone {
    Course *copy = [[[self class] alloc] init];
    copy.dept = self.dept;
    copy.title = self.title;
    copy.courseNum = self.courseNum;
    copy.credits = self.credits;
    copy.sectionNum = self.sectionNum;
    copy.type = self.type;
    copy.times = self.times;
    copy.building = self.building;
    copy.buildingCode = self.buildingCode;
    copy.roomNum = self.roomNum;
    copy.professors = self.professors;
    copy.desc = self.desc;
    copy.primaryProf = self.primaryProf;
    copy.identifier = self.identifier;
    copy.point = self.point;
    copy.sectionID = self.sectionID;
    copy.activity = self.activity;
    copy.review = self.review;
    return copy;
}

// This used to be done by identifier - but for now Title will suffice
-(bool)isEqual:(id)object {
    return [_sectionID isEqualToString:((Course *)object).sectionID];
}

- (NSUInteger)hash {
    return [_sectionID hash];
}

- (NSString *)createDetail {
    NSString *returned = [NSString stringWithFormat:@"%@ - %@\n%@-%@\n", _dept, _credits, _courseNum, _sectionNum];
    for (NSString *professor in _professors) {
        returned = [returned stringByAppendingString:professor];
        returned = [returned stringByAppendingString:@", "];
    }
    returned = [returned substringToIndex:returned.length - 2];
    returned = [returned stringByAppendingString:@"\n\n"];
    returned = [returned stringByAppendingString:_desc];
    return returned;
}
@end

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
    return [_sectionID isEqualToString:((Course *)object).title];
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

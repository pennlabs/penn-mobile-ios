//
//  Person.m
//  PennMobile
//
//  Created by Sacha Best on 9/30/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "Person.h"

@implementation Person

-(bool)isEqual:(id)object {
    return [self.identifier isEqualToString:((Person *)object).identifier];
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

- (NSString *)createDetail {
    return [NSString stringWithFormat:@"%@\nphone: %@\nemail: %@", self.title, self.email, self.phone];
}
@end

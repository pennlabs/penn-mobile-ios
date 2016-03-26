//
//  SupportItem.m
//  PennMobile
//
//  Created by Sacha Best on 1/22/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "SupportItem.h"

@implementation SupportItem

-(id)initWithName:(NSString *)name phone:(NSString*) phoneNumber {
    self = [super init];
    if(self) {
        self.name = name;
        self.phone = phoneNumber;
        self.phoneFiltered = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        self.phoneFiltered = [self.phoneFiltered stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.phoneFiltered = [self.phoneFiltered stringByReplacingOccurrencesOfString:@"(" withString:@""];
        self.phoneFiltered = [self.phoneFiltered stringByReplacingOccurrencesOfString:@")" withString:@""];
    }
    return self;
}

@end

//
//  SupportItem.h
//  PennMobile
//
//  Created by Sacha Best on 1/22/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SupportItem : NSObject

@property NSString *name;
@property NSString *phone;
@property NSString *url;
@property UIImage *img;
@property NSString *phoneFiltered;
@property NSString *descriptionText;

-(id)initWithName:(NSString *)name phone:(NSString*) phoneNumber;

@end

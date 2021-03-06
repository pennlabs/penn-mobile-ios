//
//  SupportItem.h
//  PennMobile
//
//  Created by Sacha Best on 1/22/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SupportItem : NSObject

@property NSString *name;
@property NSString *contactName;
@property NSString *phone;
@property NSString *descriptionText;
@property UIImage *img;
@property NSString *phoneFiltered;


-(id)initWithName:(NSString *)name
      contactName:(NSString *)contactName
            phone:(NSString*) phoneNumber
             desc:(NSString*) desc;

+(NSArray*) getContacts;


@end

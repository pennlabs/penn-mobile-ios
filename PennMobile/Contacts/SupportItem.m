//
//  SupportItem.m
//  PennMobile
//
//  Created by Sacha Best on 1/22/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "SupportItem.h"

@implementation SupportItem

-(id)initWithName:(NSString *)name
      contactName:(NSString *)contactName
            phone:(NSString *)phoneNumber
             desc:(NSString *)desc{
    self = [super init];
    if(self) {
        self.name = name;
        self.phone = phoneNumber;
        self.contactName = contactName;
        self.phoneFiltered = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
        self.phoneFiltered = [self.phoneFiltered stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.phoneFiltered = [self.phoneFiltered stringByReplacingOccurrencesOfString:@"(" withString:@""];
        self.phoneFiltered = [self.phoneFiltered stringByReplacingOccurrencesOfString:@")" withString:@""];
        self.descriptionText = desc;
    }
    return self;
}

+(NSArray*) getContacts
{
    SupportItem *pGeneral =
    [[SupportItem alloc] initWithName:@"Penn Police (Non-Emergency)"
                          contactName:@"Penn Police (Non-Emergency)"
                                phone:@"(215) 898-7297"
                                 desc:@"Call for all non-emergencies."];
    
    SupportItem *pEmergency =
    [[SupportItem alloc] initWithName:@"Penn Police/MERT (Emergency)"
                          contactName:@"Penn Police/MERT (Emergency)"
                                phone:@"(215) 573-3333"
                                 desc:@"Call for all criminal or medical emergencies."];
    
    SupportItem *pWalk =
    [[SupportItem alloc] initWithName:@"Penn Walk"
                          contactName:@"Penn Walk"
                                phone:@"215-898-WALK (9255)"
                                 desc:@"Call for a walking escort between 30th and 43rd Streets and Market Street and Baltimore Avenue."];
    pWalk.phoneFiltered = @"2158989255";
    
    SupportItem *pRide =
    [[SupportItem alloc] initWithName:@"Penn Ride"
                          contactName:@"Penn Ride"
                                phone:@"215-898-RIDE (7433)"
                                 desc:@"Call for Penn Ride services."];
    pRide.phoneFiltered = @"2158987433";
    
    SupportItem *hLine =
    [[SupportItem alloc] initWithName:@"Help Line"
                          contactName:@"Penn Help Line"
                                phone:@"215-898-HELP (4357)"
                                 desc:@"24-hour phone line for navigating Penn’s health and wellness resources."];
    hLine.phoneFiltered = @"2158984357";
    
    SupportItem *caps =
    [[SupportItem alloc] initWithName:@"CAPS"
                          contactName:@"Penn CAPS"
                                phone:@"215-898-7021"
                                 desc:@"Call anytime to reach Penn's Counseling and Pyschological Services Center."];
    
    SupportItem *special =
    [[SupportItem alloc] initWithName:@"Special Services"
                          contactName:@"Penn Special Services"
                                phone:@"215-898-4481"
                                 desc:@"Call to inquire or receive support services when victimized by any type of crime."];
    
    SupportItem *womens =
    [[SupportItem alloc] initWithName:@"Women's Center"
                          contactName:@"Penn Women's Center"
                                phone:@"215-898-8611"
                                 desc:@"The Women's Center sponsors programs on career development, stress management, parenting, violence prevention, and more."];
    
    SupportItem *shs =
    [[SupportItem alloc] initWithName:@"Student Health Services"
                          contactName:@"Penn Student Health Services"
                                phone:@"215-746-3535"
                                 desc:@"Call to make an appointment, contact a department, or address urgent medical issues."];
    
    return [NSArray arrayWithObjects:
     pEmergency, pGeneral, pWalk, pRide, hLine, caps, special, womens, shs, nil];
}

@end

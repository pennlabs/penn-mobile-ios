//
//  PersonTableViewCell.m
//  PennMobile
//
//  Created by Sacha Best on 9/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "PersonTableViewCell.h"

@implementation PersonTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configure:(Person *)person {
    _person = person;
    _labelName.text = [_person.firstName stringByAppendingString:_person.lastName];
    _labelRole.text = _person.affiliation;
}

@end

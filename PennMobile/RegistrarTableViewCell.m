//
//  RegistrarTableViewCell.m
//  PennMobile
//
//  Created by Sacha Best on 10/14/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "RegistrarTableViewCell.h"

@implementation RegistrarTableViewCell

- (void)awakeFromNib {
    [_labelNumber.layer setMasksToBounds:YES];
    _labelNumber.layer.cornerRadius = BORDER_RADIUS;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

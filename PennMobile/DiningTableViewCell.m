//
//  DiningTableViewCell.m
//  PennMobile
//
//  Created by Sacha Best on 9/9/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "DiningTableViewCell.h"

@implementation DiningTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self.viewForBaselineLayout addSubview:_addressLabel];
    [self.viewForBaselineLayout addSubview:_venueLabel];
    /*
    [self.viewForBaselineLayout addSubview:_openLabel];
    [_openLabel.layer setCornerRadius:108];
    [_openLabel.layer setBorderWidth:0];
    [_openLabel.layer setMasksToBounds:YES];
     */
    [self.viewForBaselineLayout addSubview:_hoursLabel];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

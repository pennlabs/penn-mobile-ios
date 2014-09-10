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
    NSLog(@"cell awake");
    [self.viewForBaselineLayout addSubview:_addressLabel];
    [self.viewForBaselineLayout addSubview:_venueLabel];
    [self.viewForBaselineLayout addSubview:_venueImage];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

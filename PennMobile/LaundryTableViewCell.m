//
//  LaundryTableViewCell.m
//  PennMobile
//
//  Created by Krishna Bharathala on 12/2/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import "LaundryTableViewCell.h"

@implementation LaundryTableViewCell

- (void)awakeFromNib {
    int height = self.frame.size.height;
    for(int i = 0; i < 3; i++) {
        UIImageView *tempImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"greenCircle"]];
        [tempImageView setFrame:CGRectMake(height*(i+1)/8, height/3, height/8, height/8)];
        [self addSubview:tempImageView];
    }
    for(int i = 3; i < 6; i++) {
        UIImageView *tempImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"redCircle"]];
        [tempImageView setFrame:CGRectMake(height*(i+1)/8, 4*height/11, height/9, height/9)];
        [self addSubview:tempImageView];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

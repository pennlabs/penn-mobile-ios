//
//  LaundryDetailTableViewCell.m
//  PennMobile
//
//  Created by Krishna Bharathala on 2/22/16.
//  Copyright © 2016 PennLabs. All rights reserved.
//

#import "LaundryWasherDetailTableViewCell.h"

@implementation LaundryWasherDetailTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier available_washers:(int) aw unavailable_washers:(int) uw {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        float height = self.frame.size.height;
        
        UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(height*2.7, 20, 300, 30)];
        [summaryLabel setText:@"Summary"];
        summaryLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        [self addSubview:summaryLabel];
        
        self.typeImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 100, 100)];
        [self.typeImage setImage:[UIImage imageNamed:@"washer_icon.png"]];
        [self addSubview:self.typeImage];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(height*2.7, 40, 300, 30)];
        self.nameLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [self addSubview:self.nameLabel];
        
        UILabel *availabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(height*2.7, 90, 300, 30)];
        availabilityLabel.text = [NSString stringWithFormat:@"%d out of %d washers available", aw, aw+uw];
        availabilityLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [self addSubview:availabilityLabel];
        
        UILabel *helperLabel = [[UILabel alloc] initWithFrame:CGRectMake(height*2.7, 110, 300, 30)];
        helperLabel.text = [NSString stringWithFormat:@"Activate switch for notification when complete"];
        helperLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [self addSubview:helperLabel];
        
        for(int i = 0; i < aw; i++) {
            CAShapeLayer *circleLayerGreen = [CAShapeLayer layer];
            [circleLayerGreen setFillColor:[UIColor greenColor].CGColor];
            [circleLayerGreen setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*2.7 + i*height/3, 80, height/4, height/4)] CGPath]];
            [[self layer] addSublayer:circleLayerGreen];
        }
        
        for(int i = aw; i < uw+aw; i++) {
            CAShapeLayer *circleLayerRed = [CAShapeLayer layer];
            [circleLayerRed setFillColor:[UIColor redColor].CGColor];
            [circleLayerRed setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*2.7 + i*height/3, 80, height/4, height/4)] CGPath]];
            [[self layer] addSublayer:circleLayerRed];
        }
        
    }
    return self;
}

@end

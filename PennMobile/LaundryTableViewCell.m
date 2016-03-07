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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier available_washers:(int) aw available_dryers:(int) ad unavailable_washers:(int) uw unavailable_dryers:(int) ud {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    if (self) {
        float height = self.frame.size.height;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, 30)];
        self.nameLabel.center = CGPointMake(self.center.x, self.center.y);
        self.nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        [self addSubview:self.nameLabel];
        
        UILabel *washerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 300, 30)];
        [washerLabel setText:@"Washers"];
        [self addSubview:washerLabel];
        
        UILabel *dryerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 65, 300, 30)];
        [dryerLabel setText:@"Dryers"];
        [self addSubview:dryerLabel];
        
        for(int i = 0; i < aw; i++) {
            CAShapeLayer *circleLayerGreen = [CAShapeLayer layer];
            [circleLayerGreen setFillColor:[UIColor greenColor].CGColor];
            [circleLayerGreen setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*2 + i*height/3, 50, height/4, height/4)] CGPath]];
            [[self layer] addSublayer:circleLayerGreen];
        }
        
        for(int i = aw; i < uw+aw; i++) {
            CAShapeLayer *circleLayerRed = [CAShapeLayer layer];
            [circleLayerRed setFillColor:[UIColor redColor].CGColor];
            [circleLayerRed setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*2 + i*height/3, 50, height/4, height/4)] CGPath]];
            [[self layer] addSublayer:circleLayerRed];
        }
        
        for(int i = 0; i < ad; i++) {
            CAShapeLayer *circleLayerGreen = [CAShapeLayer layer];
            [circleLayerGreen setFillColor:[UIColor greenColor].CGColor];
            [circleLayerGreen setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*2 + i*height/3, 75, height/4, height/4)] CGPath]];
            [[self layer] addSublayer:circleLayerGreen];
        }
        
        for(int i = ad; i < ud+ad; i++) {
            CAShapeLayer *circleLayerRed = [CAShapeLayer layer];
            [circleLayerRed setFillColor:[UIColor redColor].CGColor];
            [circleLayerRed setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*2 + i*height/3, 75, height/4, height/4)] CGPath]];
            [[self layer] addSublayer:circleLayerRed];
        }
        
    }
    return self;
}

@end

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
    
    NSLog(@"WASHERS A: %d\n", self.available_washers);
    NSLog(@"WASHERS U: %d\n", self.unavailable_washers);
    NSLog(@"Dryers A: %d\n", self.available_dryers);
    NSLog(@"DRYERS U: %d\n", self.unavailable_dryers);
    
    for(int i = 0; i < self.available_washers; i++) {
        CAShapeLayer *circleLayerGreen = [CAShapeLayer layer];
        [circleLayerGreen setFillColor:[UIColor greenColor].CGColor];
        [circleLayerGreen setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*4/5 + i*height/4, height/2-height/16, height/8, height/8)] CGPath]];
        [[self layer] addSublayer:circleLayerGreen];
    }
    
    for(int i = self.available_washers; i < self.unavailable_washers+self.available_washers; i++) {
        CAShapeLayer *circleLayerRed = [CAShapeLayer layer];
        [circleLayerRed setFillColor:[UIColor redColor].CGColor];
        [circleLayerRed setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*4/5 + i*height/4, height/2-height/16, height/8, height/8)] CGPath]];
        [[self layer] addSublayer:circleLayerRed];
    }
    
    for(int i = 0; i < self.available_dryers; i++) {
        CAShapeLayer *circleLayerGreen = [CAShapeLayer layer];
        [circleLayerGreen setFillColor:[UIColor greenColor].CGColor];
        [circleLayerGreen setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*4/5 + i*height/4, height*3/4-height/16, height/8, height/8)] CGPath]];
        [[self layer] addSublayer:circleLayerGreen];
    }
    
    for(int i = self.available_dryers; i < self.unavailable_dryers+self.available_dryers; i++) {
        CAShapeLayer *circleLayerRed = [CAShapeLayer layer];
        [circleLayerRed setFillColor:[UIColor redColor].CGColor];
        [circleLayerRed setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*4/5 + i*height/4, height*3/4-height/16, height/8, height/8)] CGPath]];
        [[self layer] addSublayer:circleLayerRed];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

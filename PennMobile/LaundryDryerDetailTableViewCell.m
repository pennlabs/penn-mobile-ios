//
//  LaundryDryerDetailTableViewCell.m
//  PennMobile
//
//  Created by Krishna Bharathala on 2/22/16.
//  Copyright © 2016 PennLabs. All rights reserved.
//

#import "LaundryDryerDetailTableViewCell.h"

@implementation LaundryDryerDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier available_dryers:(int) ad unavailable_dryers:(int) ud {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        float height = self.frame.size.height;
        
        UILabel *summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(height*2.7, 20, 300, 30)];
        [summaryLabel setText:@"Summary"];
        summaryLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        [self addSubview:summaryLabel];
        
        self.typeImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 100, 100)];
        [self addSubview:self.typeImage];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self.typeImage setImage:[UIImage imageNamed:@"dryer_icon.png"]];

        });
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(height*2.7, 40, 300, 30)];
        self.nameLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [self addSubview:self.nameLabel];
        
        self.availabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(height*2.7, 90, 300, 30)];
        self.availabilityLabel.text = [NSString stringWithFormat:@"%d out of %d dryers available", ad, ad+ud];
        self.availabilityLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [self addSubview:self.availabilityLabel];
        
        UILabel *helperLabel = [[UILabel alloc] initWithFrame:CGRectMake(height*2.7, 110, 300, 30)];
        helperLabel.text = [NSString stringWithFormat:@"Activate switch for notification when complete"];
        helperLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
        [self addSubview:helperLabel];
        
        for(int i = 0; i < ad; i++) {
            CAShapeLayer *circleLayerGreen = [CAShapeLayer layer];
            [circleLayerGreen setFillColor:[UIColor greenColor].CGColor];
            [circleLayerGreen setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*2.7 + i*height/3, 80, height/4, height/4)] CGPath]];
            [[self layer] addSublayer:circleLayerGreen];
        }
        
        for(int i = ad; i < ud+ad; i++) {
            CAShapeLayer *circleLayerRed = [CAShapeLayer layer];
            [circleLayerRed setFillColor:[UIColor redColor].CGColor];
            [circleLayerRed setPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectMake(height*2.7 + i*height/3, 80, height/4, height/4)] CGPath]];
            [[self layer] addSublayer:circleLayerRed];
        }
        
    }
    return self;
    
}


@end

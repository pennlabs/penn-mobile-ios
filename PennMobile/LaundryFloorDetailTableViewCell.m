//
//  LaundryFloorDetailTableViewCell.m
//  PennMobile
//
//  Created by Krishna Bharathala on 2/13/16.
//  Copyright © 2016 PennLabs. All rights reserved.
//

#import "LaundryFloorDetailTableViewCell.h"

@implementation LaundryFloorDetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // configure control(s)
        self.mySwitch = [[UISwitch alloc] init];
        self.mySwitch.center = CGPointMake(self.center.x, self.frame.size.width-40);
        
        //[self addSubview:self.mySwitch];
    }
    return self;
}

@end

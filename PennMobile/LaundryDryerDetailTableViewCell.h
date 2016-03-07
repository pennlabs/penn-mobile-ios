//
//  LaundryDryerDetailTableViewCell.h
//  PennMobile
//
//  Created by Krishna Bharathala on 2/22/16.
//  Copyright © 2016 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LaundryDryerDetailTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *typeImage;
@property (strong, nonatomic) UILabel *availabilityLabel;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
   available_dryers:(int) ad
 unavailable_dryers:(int) ud;


@end

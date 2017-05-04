//
//  LaundryDetailTableViewCell.h
//  PennMobile
//
//  Created by Krishna Bharathala on 2/22/16.
//  Copyright © 2016 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LaundryWasherDetailTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *typeImage;
@property (strong, nonatomic) UILabel *availabilityLabel;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
  available_washers:(int) aw
   unavailable_washers:(int) ud;
@end

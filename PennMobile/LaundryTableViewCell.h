//
//  LaundryTableViewCell.h
//  PennMobile
//
//  Created by Krishna Bharathala on 12/2/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LaundryTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
  available_washers:(int) aw
  available_dryers:(int) ad
  unavailable_washers:(int) uw
  unavailable_dryers:(int) ud;

@end

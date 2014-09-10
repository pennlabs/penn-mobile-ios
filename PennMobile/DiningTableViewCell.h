//
//  DiningTableViewCell.h
//  PennMobile
//
//  Created by Sacha Best on 9/9/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiningTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *venueLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property IBOutlet UIImageView *venueImage;

@end

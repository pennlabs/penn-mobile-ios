//
//  LaundryTableViewCell.h
//  PennMobile
//
//  Created by Krishna Bharathala on 12/2/15.
//  Copyright © 2015 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LaundryTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property int available_washers;
@property int unavailable_washers;
@property int available_dryers;
@property int unavailable_dryers;

@end

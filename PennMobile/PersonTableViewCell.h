//
//  PersonTableViewCell.h
//  PennMobile
//
//  Created by Sacha Best on 9/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelRole;
@property (weak, nonatomic) IBOutlet UIButton *buttonCall;
@property (weak, nonatomic) IBOutlet UIButton *buttonText;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmail;

@end

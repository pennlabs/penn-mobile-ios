//
//  PersonTableViewCell.m
//  PennMobile
//
//  Created by Sacha Best on 9/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "PersonTableViewCell.h"

@implementation PersonTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [[_buttonCall imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [[_buttonText imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [[_buttonEmail imageView] setContentMode: UIViewContentModeScaleAspectFit];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)promptPhone:(id)sender {
    UIAlertView *phoneAlert = [[UIAlertView alloc] initWithTitle:_person.name message:@"Would you like to call or text?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", @"Text", nil];
    [phoneAlert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *phoneNumber = [@"tel://" stringByAppendingString:_person.phone];
    NSString *textNumber = [@"sms://" stringByAppendingString:_person.phone];
    switch (buttonIndex) {
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            break;
        case 2:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:textNumber]];
            break;
    }
}
-(IBAction)promptEmail:(id)sender {
    NSString *email = [@"mailto://" stringByAppendingString:_person.email];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}
-(void)configure:(Person *)person {
    _person = person;
    _labelName.text = _person.name;
    _labelRole.text = _person.organization;
    if (_person.email) {
        [_buttonEmail setTitle:_person.email forState:UIControlStateNormal];
    }
    if (_person.phone) {
        [_buttonCall setTitle:_person.phone forState:UIControlStateNormal];
    }
}
@end

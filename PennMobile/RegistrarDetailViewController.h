//
//  RegistrarDetailViewController.h
//  PennMobile
//
//  Created by Krishna Bharathala on 8/22/16.
//  Copyright © 2016 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Course.h"

@interface RegistrarDetailViewController : UIViewController

-(instancetype) initWithCourse:(Course *)course;

@property (nonatomic, strong) Course *course;

@end

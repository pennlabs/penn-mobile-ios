//
//  RegistrarDetailViewController.m
//  PennMobile
//
//  Created by Krishna Bharathala on 8/22/16.
//  Copyright © 2016 PennLabs. All rights reserved.
//

#import "RegistrarDetailViewController.h"
#import "PCRAggregator.h"

@interface RegistrarDetailViewController ()

@end

@implementation RegistrarDetailViewController

const CGFloat button_height = 54.0f;

-(instancetype) initWithCourse:(Course *)course {
    self = [super init];
    if (self) {
        self.course = course;
        self.title = course.sectionID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    [backButtonItem setTintColor: PENN_YELLOW];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    float navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 32 + navBarHeight, width - 32, 0)];
    subtitleLabel.text = self.course.title;
    subtitleLabel.numberOfLines = 0;
    [subtitleLabel sizeToFit];
    float subtitleLabelBottom = subtitleLabel.frame.origin.y + subtitleLabel.frame.size.height;
    [self.view addSubview:subtitleLabel];
    
    UILabel *typeLabel = [[UILabel alloc] init];
    typeLabel.frame = CGRectMake(16, 16 + subtitleLabelBottom, width - 32, 0);
    typeLabel.text = self.course.activity;
    typeLabel.textColor = [UIColor grayColor];
    typeLabel.font = [UIFont systemFontOfSize:12.0f];
    [typeLabel sizeToFit];
    float typeLabelBottom = typeLabel.frame.origin.y + typeLabel.frame.size.height;
    [self.view addSubview:typeLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.frame = CGRectMake(16, 4 + typeLabelBottom, width - 32, 0);
    timeLabel.text = self.course.times;
    timeLabel.textColor = [UIColor grayColor];
    timeLabel.font = [UIFont systemFontOfSize:12.0f];
    [timeLabel sizeToFit];
    float timeLabelRight = timeLabel.frame.origin.x + timeLabel.frame.size.width;
    float timeLabelBottom = timeLabel.frame.origin.y + timeLabel.frame.size.height;
    [self.view addSubview:timeLabel];
    
    UILabel *roomLabel = [[UILabel alloc] init];
    roomLabel.frame = CGRectMake(16, 4 + timeLabelBottom, width - 32, 0);
    roomLabel.text = self.course.roomNum;
    roomLabel.textColor = [UIColor grayColor];
    roomLabel.font = [UIFont systemFontOfSize:12.0f];
    [roomLabel sizeToFit];
    float roomLabelBottom = roomLabel.frame.origin.y + roomLabel.frame.size.height;
    [self.view addSubview:roomLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.frame = CGRectMake(16, 16 + roomLabelBottom, width - 32, 0);
    descriptionLabel.text = self.course.desc;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    [self.view addSubview:descriptionLabel];
    
    PCReview *review = [PCRAggregator getAverageReviewFor:self.course];
    
    UIButton *diffButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    diffButton.frame = CGRectMake(timeLabelRight + 8, typeLabel.frame.origin.y, button_height, button_height);
    diffButton.layer.cornerRadius = 10;
    diffButton.clipsToBounds = YES;
    diffButton.backgroundColor = [UIColor blueColor];
    diffButton.userInteractionEnabled = NO;
    [diffButton setTitle:[NSString stringWithFormat: @"%.1f", review.diff] forState:UIControlStateNormal];
    diffButton.titleLabel.textColor = [UIColor whiteColor];
    diffButton.titleLabel.alpha = 1.0;
    float diffButtonRight = diffButton.frame.origin.x + button_height;
    [self.view addSubview:diffButton];
    
    UIButton *courseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    courseButton.frame = CGRectMake(diffButtonRight + 8, typeLabel.frame.origin.y, button_height, button_height);
    courseButton.layer.cornerRadius = 10;
    courseButton.clipsToBounds = YES;
    courseButton.backgroundColor = [UIColor blueColor];
    courseButton.userInteractionEnabled = NO;
    [courseButton setTitle:[NSString stringWithFormat: @"%.1f", review.course] forState:UIControlStateNormal];
    courseButton.titleLabel.textColor = [UIColor whiteColor];
    courseButton.titleLabel.alpha = 1.0;
    float courseButtonRight = courseButton.frame.origin.x + button_height;
    [self.view addSubview:courseButton];
    
    UIButton *instButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    instButton.frame = CGRectMake(courseButtonRight + 8, typeLabel.frame.origin.y, button_height, button_height);
    instButton.layer.cornerRadius = 10;
    instButton.clipsToBounds = YES;
    instButton.backgroundColor = [UIColor blueColor];
    instButton.userInteractionEnabled = NO;
    [instButton setTitle:[NSString stringWithFormat: @"%.1f", review.inst] forState:UIControlStateNormal];
    instButton.titleLabel.textColor = [UIColor whiteColor];
    instButton.titleLabel.alpha = 1.0;
    [self.view addSubview:instButton];
    
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

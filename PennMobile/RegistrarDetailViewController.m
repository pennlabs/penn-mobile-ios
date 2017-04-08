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

CGFloat screen_height;
CGFloat screen_width;
CGFloat button_dimension;

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
    
    screen_height = [UIScreen mainScreen].bounds.size.height;
    screen_width = [UIScreen mainScreen].bounds.size.width;
    button_dimension = screen_height * 0.16;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *backButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                         style:UIBarButtonItemStyleDone
                                        target:self
                                        action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    [backButtonItem setTintColor: PENN_YELLOW];
    
    float width = self.view.frame.size.width;
    float navBarHeight = self.navigationController.navigationBar.frame.size.height;
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 32 + navBarHeight, width - 32, 0)];
    subtitleLabel.text = self.course.title;
    [subtitleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:18]];
    [subtitleLabel setTextColor: [UIColor colorWithRed:  115/255.0f green: 115/255.0f blue: 115/255.0f alpha:1]];
    subtitleLabel.numberOfLines = 0;
    [subtitleLabel sizeToFit];
    float subtitleLabelBottom = subtitleLabel.frame.origin.y + subtitleLabel.frame.size.height;
    [self.view addSubview:subtitleLabel];
    
    UILabel *typeLabel = [[UILabel alloc] init];
    typeLabel.frame = CGRectMake(16, 8 + subtitleLabelBottom, width - 32, 0);
    typeLabel.text = self.course.activity;
    typeLabel.textColor = [UIColor grayColor];
    typeLabel.font = [UIFont systemFontOfSize:12.0f];
    [typeLabel sizeToFit];
    float typeLabelBottom = typeLabel.frame.origin.y + typeLabel.frame.size.height;
    [self.view addSubview:typeLabel];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    timeLabel.frame = CGRectMake(16, 4 + typeLabelBottom, width - 32, 0);
    if ([self.course.times  isEqual: @"(null) (null)-(null)"]) {
        timeLabel.text = @"N/A";
    } else {
        timeLabel.text = self.course.times;
    }
    timeLabel.textColor = [UIColor grayColor];
    timeLabel.font = [UIFont systemFontOfSize:12.0f];
    [timeLabel sizeToFit];
    float timeLabelBottom = timeLabel.frame.origin.y + timeLabel.frame.size.height;
    [self.view addSubview:timeLabel];
    
    UILabel *profLabel = [[UILabel alloc] init];
    profLabel.frame = CGRectMake(16, 4 + timeLabelBottom, width - 32, 0);
    if ([self.course.primaryProf isEqual: @"null"]) {
        profLabel.text = @"N/A";
    } else {
        profLabel.text = self.course.primaryProf;
    }
    profLabel.textColor = [UIColor grayColor];
    profLabel.font = [UIFont systemFontOfSize:12.0f];
    [profLabel sizeToFit];
    [self.view addSubview:profLabel];

    
    PCReview *review = [PCRAggregator getAverageReviewFor:self.course];
    
    UIButton *courseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    courseButton.frame = CGRectMake(subtitleLabel.frame.origin.x, timeLabelBottom + 8 + screen_height * 0.037, button_dimension, button_dimension);
    courseButton.layer.cornerRadius = 10;
    courseButton.clipsToBounds = YES;
    [courseButton setBackgroundColor:[UIColor colorWithRed: 149/255.0f green: 207/255.0f blue: 175/255.0f alpha:1]];
    courseButton.userInteractionEnabled = NO;
    if ((int) review.course != 0) {
        [courseButton setTitle:[NSString stringWithFormat: @"%.1f", review.course] forState:UIControlStateNormal];
    } else {
        [courseButton setTitle:[NSString stringWithFormat: @"%s", "N/A"] forState:UIControlStateNormal];
    }
    //proper way to set text color
    [courseButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    [courseButton.titleLabel setFont:[UIFont systemFontOfSize:40]];
    courseButton.titleLabel.alpha = 1.0;
    float courseButtonRight = courseButton.frame.origin.x + button_dimension;
    float courseButtonBottom = courseButton.frame.origin.y + button_dimension;
    [self.view addSubview:courseButton];
    
    UIButton *instButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    instButton.frame = CGRectMake(courseButtonRight + screen_width * 0.035, timeLabelBottom + 8 + screen_height * 0.037, button_dimension, button_dimension);
    instButton.layer.cornerRadius = 10;
    instButton.clipsToBounds = YES;
    [instButton setBackgroundColor:[UIColor colorWithRed: 73/255.0f green: 144/255.0f blue: 226/255.0f alpha:1]];
    instButton.userInteractionEnabled = NO;
    if ((int) review.inst != 0) {
        [instButton setTitle:[NSString stringWithFormat: @"%.1f", review.inst] forState:UIControlStateNormal];
    } else {
        [instButton setTitle:[NSString stringWithFormat: @"%s", "N/A"] forState:UIControlStateNormal];
    }
    [instButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    [instButton.titleLabel setFont:[UIFont systemFontOfSize:40]];
    instButton.titleLabel.alpha = 1.0;
    float instButtonRight = instButton.frame.origin.x + button_dimension;
    float instButtonBottom = instButton.frame.origin.y + button_dimension;
    [self.view addSubview:instButton];
    
    UIButton *diffButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    diffButton.frame = CGRectMake(instButtonRight  + screen_width * 0.035, timeLabelBottom + 8 + screen_height * 0.037, button_dimension, button_dimension);
    diffButton.layer.cornerRadius = 10;
    diffButton.clipsToBounds = YES;
    [diffButton setBackgroundColor:[UIColor colorWithRed:  242/255.0f green: 110/255.0f blue: 103/255.0f alpha:1]];
    [diffButton.titleLabel setFont:[UIFont systemFontOfSize:40]];
    diffButton.userInteractionEnabled = NO;
    if ((int) review.diff != 0) {
        [diffButton setTitle:[NSString stringWithFormat: @"%.1f", review.diff] forState:UIControlStateNormal];
    } else {
        [diffButton setTitle:[NSString stringWithFormat: @"%s", "N/A"] forState:UIControlStateNormal];
    }
    [diffButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
    diffButton.titleLabel.alpha = 1.0;
    float diffButtonRight = diffButton.frame.origin.x + button_dimension;
    float diffButtonBottom = diffButton.frame.origin.y + button_dimension;
    [self.view addSubview:diffButton];
    
    
    UILabel *courseLabel = [[UILabel alloc] init];
    courseLabel.frame = CGRectMake(courseButton.frame.origin.x + button_dimension * 0.23,  courseButtonBottom + screen_height * 0.011, button_dimension, 0);
    courseLabel.text = @"Course";
    [courseLabel setTextColor: [UIColor colorWithRed:  115/255.0f green: 115/255.0f blue: 115/255.0f alpha:1]];
    [courseLabel sizeToFit];
    courseLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:courseLabel];
    
    UILabel *instLabel = [[UILabel alloc] init];
    instLabel.frame = CGRectMake(instButton.frame.origin.x + button_dimension * 0.15, instButtonBottom + screen_height * 0.011, button_dimension, 0);
    instLabel.text = @"Instructor";
    [instLabel setTextColor: [UIColor colorWithRed:  115/255.0f green: 115/255.0f blue: 115/255.0f alpha:1]];
    [instLabel sizeToFit];
    instLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:instLabel];
    
    UILabel *diffLabel = [[UILabel alloc] init];
    diffLabel.frame = CGRectMake(diffButton.frame.origin.x + button_dimension * 0.18, diffButtonBottom + screen_height * 0.011, button_dimension, 0);
    diffLabel.text = @"Difficulty";
    [diffLabel setTextColor: [UIColor colorWithRed:  115/255.0f green: 115/255.0f blue: 115/255.0f alpha:1]];
    [diffLabel sizeToFit];
    diffLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:diffLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.frame = CGRectMake(0, 0, width - 32, 0);
    descriptionLabel.text = self.course.desc;
    [descriptionLabel setTextColor: [UIColor colorWithRed:  115/255.0f green: 115/255.0f blue: 115/255.0f alpha:1]];
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(courseButton.frame.origin.x, courseButtonBottom + screen_height * 0.067, width - 32, screen_height * 0.434)];
    //Must set this in order to scroll. If content height is less then it won't scroll
    scrollView.contentSize = CGSizeMake(0, descriptionLabel.frame.size.height);
    [scrollView setScrollEnabled:true];
    [scrollView setUserInteractionEnabled:true];
    [scrollView addSubview:descriptionLabel];
    [self.view addSubview:scrollView];
    
}

-(void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

@end

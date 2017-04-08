//
//  AboutViewController.m
//  PennMobile
//
//  Created by Sacha Best and Krishna Bharathala.
//  Copyright (c) 2016 PennLabs. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

-(id) init {
    self = [super init];
    if(self) {
        self.title = @"About";
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = PENN_YELLOW;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
}

-(void) viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    UIImageView *labsLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NewLabsLogo.png"]];
    [labsLogo setFrame:CGRectMake(0, 0, 240, 120)];
    labsLogo.center = CGPointMake(width*1/2, height*5/16);
    [self.view addSubview:labsLogo];
    
    UILabel *builtLabel = [[UILabel alloc] init];
    builtLabel.text = @"Built by Penn Labs";
    [builtLabel setTextColor:[UIColor blackColor]];
    [builtLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [builtLabel sizeToFit];
    builtLabel.center = CGPointMake(width/2, height*15/32);
    [self.view addSubview:builtLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = @"Penn Labs is a non-profit, student-run organization at the University of Pennsylvania dedicated to building technology for student use and supporting an open-source development environment on-campus. Penn Labs is sponsored by the UA, the Provost’s Office and VPUL.";
    [descriptionLabel setTextColor:[UIColor darkGrayColor]];
    [descriptionLabel setFrame:CGRectMake(0, 0, width-40, height/3)];
    [descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.center = CGPointMake(width/2, height*19/32);
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:descriptionLabel];
    
    UILabel *peopleLabel = [[UILabel alloc] init];
    peopleLabel.text = @"Developed by Sacha Best, Krishna Bharathala, Josh Doman, and Victor Chien\n Designed by Sacha Best and Tiffany Chang\n Thanks to Adel Qalieh, David Lakata\n and the rest of Labs + UA";
    [peopleLabel setTextColor:[UIColor darkGrayColor]];
    [peopleLabel setFrame:CGRectMake(0, 0, width-40, height/3)];
    [peopleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    peopleLabel.numberOfLines = 0;
    peopleLabel.center = CGPointMake(width/2, height*3/4);
    peopleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:peopleLabel];
    
    UILabel *copyRightLabel = [[UILabel alloc] init];
    copyRightLabel.text = @"\u00A9 2016 Penn Labs";
    [copyRightLabel setTextColor:[UIColor darkGrayColor]];
    [copyRightLabel setFrame:CGRectMake(0, 0, width-40, height/3)];
    [copyRightLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:14]];
    copyRightLabel.center = CGPointMake(width/2, height*13/14);
    copyRightLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:copyRightLabel];
    
    UIButton *featureRequestButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [featureRequestButton setTitle:@"Feature Request" forState:UIControlStateNormal];
    [featureRequestButton setFrame:CGRectMake(0, 0, 150, 30)];
    [featureRequestButton setCenter:CGPointMake(width/3, height*6/7)];
    [featureRequestButton addTarget:self action:@selector(featureRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:featureRequestButton];
    
    UIButton *moreInfoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [moreInfoButton setTitle:@"More Info" forState:UIControlStateNormal];
    [moreInfoButton setFrame:CGRectMake(0, 0, 150, 30)];
    [moreInfoButton setCenter:CGPointMake(width*2/3, height*6/7)];
    [moreInfoButton addTarget:self action:@selector(moreInfo) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:moreInfoButton];
    
    
    
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:revealController
                                                                        action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
}

- (void) featureRequest {
    NSString *messageSubject = @"[Penn iOS] Request: ";
    NSArray *toRecipents = [NSArray arrayWithObject:@"contact@pennlabs.org"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    mc.mailComposeDelegate = self;
    [mc setSubject:messageSubject];
    [mc setToRecipients:toRecipents];

    [self presentViewController:mc animated:YES completion:nil];
}
- (void)moreInfo {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://pennlabs.org"]];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end

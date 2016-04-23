//
//  NewsViewController.m
//  PennMobile
//
//  Created by Krishna Bharathala on 4/23/16.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController ()

@property (nonatomic, strong) UISegmentedControl *newsSwitcher;
@property (nonatomic, strong) UIView *newsSwitcherView;
@property (nonatomic, strong) NSArray *segmentTitles;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIImageView *navBarHairlineImageView;

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) NSString *url;

@end

@implementation NewsViewController

-(id) init {
    self = [super init];
    if(self) {
        self.title = @"News";
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = PENN_YELLOW;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    self.navBarHairlineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    self.navBarHairlineImageView.hidden = YES;
    
    self.revealViewController.panGestureRecognizer.enabled = NO;
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navBarHairlineImageView.hidden = NO;
    self.revealViewController.panGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    SWRevealViewController *revealController = [self revealViewController];
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal-icon.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:revealController
                                                                        action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = revealButtonItem;
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 64, width, 44)];
    self.toolbar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    self.toolbar.delegate = self;
    
    self.newsSwitcher = [[UISegmentedControl alloc] initWithItems: @[@"theDP", @"UTB", @"34th Street"]];
    self.newsSwitcher.center = CGPointMake(width/2, self.toolbar.frame.size.height/2);
    self.newsSwitcher.tintColor = PENN_YELLOW;
    self.newsSwitcher.selectedSegmentIndex = 0;
    [self.newsSwitcher addTarget:self action:@selector(switchNewsSource:) forControlEvents:UIControlEventValueChanged];

    [self.toolbar addSubview:self.newsSwitcher];
    [self.view addSubview:self.toolbar];
    
    self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 108, width, height-108)];
    self.webview.scrollView.backgroundColor = [UIColor whiteColor];
    self.webview.delegate = self;
    [self.view addSubview: self.webview];
    
    NSString *url=@"http://thedp.com/";
    NSURL *nsurl=[NSURL URLWithString:url];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [self.webview loadRequest:nsrequest];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//}
//
//- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    NSLog(@"%@", error.localizedDescription);
//}

-(void)switchNewsSource:(UISegmentedControl *)segment {
    NSArray *urlArray = @[@"http://thedp.com/", @"http://thedp.com/blog/under-the-button/", @"http://34st.com/"];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlArray[segment.selectedSegmentIndex]]]];
}

- (void)didSwipe:(UISwipeGestureRecognizer*) swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        if ([self.webview canGoBack]) {
            [self.webview goBack];
        }
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        if ([self.webview canGoForward]) {
            [self.webview goForward];
        }
    }
}

@end

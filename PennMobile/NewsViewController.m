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
@property (nonatomic, strong) UIToolbar *headerToolbar;
@property (nonatomic, strong) UIImageView *navBarHairlineImageView;

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) NSArray *urlArray;

@end

@implementation NewsViewController

-(id) init {
    self = [super init];
    if(self) {
        self.title = @"News";
        self.urlArray = @[@"http://thedp.com/", @"http://thedp.com/blog/under-the-button/", @"http://34st.com/"];
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.tintColor = PENN_YELLOW;
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    self.navigationController.toolbarHidden = NO;
    
    self.navBarHairlineImageView =
        [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    [self.navBarHairlineImageView setHidden:YES];
//    NSLog(@"%@", NSStringFromCGRect(self.navBarHairlineImageView.frame));
//    self.navBarHairlineImageView.frame = CGRectOffset(self.navBarHairlineImageView.frame, 0, 44);
//    NSLog(@"%@", NSStringFromCGRect(self.navBarHairlineImageView.frame));
    
    self.revealViewController.panGestureRecognizer.enabled = NO;
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navBarHairlineImageView.hidden = NO;
    self.navigationController.toolbarHidden = YES;
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
    
    
    UIImage *fwdImage =
        [self imageWithImage:[UIImage imageNamed:@"arrow-fwd"] scaledToSize:CGSizeMake(20, 20)];
    UIBarButtonItem *fwdButton = [[UIBarButtonItem alloc] initWithImage:fwdImage
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(fwdRequested)];
    
    UIImage *bwdImage =
        [self imageWithImage:[UIImage imageNamed:@"arrow-bwd"] scaledToSize:CGSizeMake(20, 20)];
    UIBarButtonItem *bwdButton = [[UIBarButtonItem alloc] initWithImage:bwdImage
                                                                  style:UIBarButtonItemStyleDone
                                                                 target:self
                                                                 action:@selector(bwdRequested)];
    
    NSArray *buttons = [NSArray arrayWithObjects: bwdButton, fwdButton, nil];
    [self setToolbarItems:buttons];
    [self.navigationController.toolbar setTintColor:PENN_YELLOW];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    self.headerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 64, width, 44)];
    self.headerToolbar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
    self.headerToolbar.delegate = self;
    
    self.newsSwitcher = [[UISegmentedControl alloc] initWithItems: @[@"theDP", @"UTB", @"34th Street"]];
    self.newsSwitcher.center = CGPointMake(width/2, self.headerToolbar.frame.size.height/2);
    self.newsSwitcher.tintColor = PENN_YELLOW;
    self.newsSwitcher.selectedSegmentIndex = 0;
    [self.newsSwitcher addTarget:self
                          action:@selector(switchNewsSource:)
                forControlEvents:UIControlEventValueChanged];

    [self.headerToolbar addSubview:self.newsSwitcher];
    [self.view addSubview:self.headerToolbar];
    
    self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 108, width, height-152)];
    self.webview.delegate = self;
    self.webview.scrollView.backgroundColor = [UIColor whiteColor];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.urlArray firstObject]]]];
    [self.view addSubview: self.webview];
    
    UISwipeGestureRecognizer *swipeRight =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft =
        [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    // UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
    [self.webview loadRequest:
     [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlArray[segment.selectedSegmentIndex]]]];
}

- (void)didSwipe:(UISwipeGestureRecognizer*) swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        [self bwdRequested];
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self fwdRequested];
    }
}

-(void)fwdRequested {
    if ([self.webview canGoForward]) {
        [self.webview goForward];
    }
}

-(void)bwdRequested {
    if ([self.webview canGoBack]) {
        [self.webview goBack];
    }
}

@end

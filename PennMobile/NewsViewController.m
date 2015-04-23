//
//  NewsViewController.m
//  PennMobile
//
//  Created by Sacha Best on 11/13/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController ()
@property BOOL isToggleEnabled;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *toggle;
@end

@implementation NewsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:_url]];
    [_webView loadRequest:req];
    _webView.scalesPageToFit = NO;
    _webView.delegate = self;
    
    _isToggleEnabled = YES;
    [_newsSwitcher addTarget:self action:@selector(switchNewsSource:) forControlEvents:UIControlEventValueChanged];
    UITapGestureRecognizer *newsSwitcherTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(collapseNewsSwitcher:)];
    newsSwitcherTap.cancelsTouchesInView = NO;
    [_newsSwitcher addGestureRecognizer:newsSwitcherTap];
    
    [_loadingIndicator stopAnimating];
    _loadingIndicator.hidesWhenStopped = YES;
    _loadingIndicator.color = PENN_RED;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    NSLog(@"start");
    
    //   [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_loadingIndicator startAnimating];
    NSString *url =_webView.request.URL.absoluteString;
    if ([url containsString:@"thedp.com/blog/under-the-button"]) {
        [_newsSwitcher setSelectedSegmentIndex:1];
    } else if ([url containsString:@"thedp.com"]) {
        [_newsSwitcher setSelectedSegmentIndex:0];
    } else if ([url containsString:@"34st.com"]) {
        [_newsSwitcher setSelectedSegmentIndex:2];
    } else if ([url containsString:@"eventsatpenn.com"]) {
        [_newsSwitcher setSelectedSegmentIndex:3];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"finish");
    
    
    if (!webView.isLoading) {
//     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }
    [_loadingIndicator stopAnimating];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleControl:(id)sender {
    if (_isToggleEnabled) {
        NSLog(@"news switcher is hidden");
        [UIView animateWithDuration:0.3 animations:^{
            _newsSwitcher.frame = CGRectMake(_newsSwitcher.frame.origin.x, _newsSwitcher.frame.origin.y + _newsSwitcher.frame.size.height, _newsSwitcher.frame.size.width, _newsSwitcher.frame.size.height);
        }];
        _isToggleEnabled = NO;
    } else {
        NSLog(@"news switcher is NOT hidden");
        [UIView animateWithDuration:0.3 animations:^{
            _newsSwitcher.frame = CGRectMake(_newsSwitcher.frame.origin.x, _newsSwitcher.frame.origin.y - _newsSwitcher.frame.size.height, _newsSwitcher.frame.size.width, _newsSwitcher.frame.size.height);
        }];
        _isToggleEnabled = YES;
    }
}

-(void)collapseNewsSwitcher:(UITapGestureRecognizer *)recognizer {
    [_toggle sendActionsForControlEvents: UIControlEventTouchUpInside];
}

-(void)switchNewsSource:(UISegmentedControl *)segment {
    switch (segment.selectedSegmentIndex) {
        case 0:{
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://thedp.com/"]]];
            break;}
        case 1:{
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://thedp.com/blog/under-the-button/"]]];
            break;}
        case 2:{
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://34st.com/"]]];
            break;}
        case 3:{
            [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://eventsatpenn.com/"]]];
            break;}
    }

}

- (IBAction)webViewBack:(id)sender {
    if ([_webView canGoBack]) {
        [_webView goBack];
        NSString* url = _webView.request.URL.absoluteString;
        //NSLog(url);///stopped working here
        
    }
}

#pragma mark - Navigation

/**
 * This fragment is repeated across the app, still don't know the best way to refactor
 **/
- (IBAction)menuButton:(id)sender {
    if ([SlideOutMenuViewController instance].menuOut) {
        // this is a workaround as the normal returnToView selector causes a fault
        // the memory for hte instance is locked unless the view controller is passed in a segue
        // this is for security reasons.
        [[SlideOutMenuViewController instance] performSegueWithIdentifier:self.navigationItem.title sender:self];
    } else {
        [self performSegueWithIdentifier:@"menu" sender:self];
    }
}
- (void)handleRollBack:(UIStoryboardSegue *)segue {
    if ([segue.destinationViewController isKindOfClass:[SlideOutMenuViewController class]]) {
        SlideOutMenuViewController *menu = segue.destinationViewController;
        cancelTouches = [[UITapGestureRecognizer alloc] initWithTarget:menu action:@selector(returnToView:)];
        cancelTouches.cancelsTouchesInView = YES;
        cancelTouches.numberOfTapsRequired = 1;
        cancelTouches.numberOfTouchesRequired = 1;
        if (self.view.gestureRecognizers.count > 0) {
            // there is a keybaord dismiss tap recognizer present
            // ((UIGestureRecognizer *) self.view.gestureRecognizers[0]).enabled = NO;
        }
        float width = [[UIScreen mainScreen] bounds].size.width;
        float height = [[UIScreen mainScreen] bounds].size.height;
        UIView *grayCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [grayCover setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
        [grayCover addGestureRecognizer:cancelTouches];
        [UIView transitionWithView:self.view duration:1
                           options:UIViewAnimationOptionShowHideTransitionViews
                        animations:^ { [self.view addSubview:grayCover]; }
                        completion:nil];
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    [self handleRollBack:segue];
}


@end

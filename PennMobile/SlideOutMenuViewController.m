//
//  SlideOutMenuViewController.m
//  PennMobile
//
//  Created by Sacha Best on 12/17/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "SlideOutMenuViewController.h"

@interface SlideOutMenuViewController ()

@end

@implementation SlideOutMenuViewController

static SlideOutMenuViewController *instance;

+ (SlideOutMenuViewController *)instance {
    return instance;
}
- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue { }

- (void)viewDidLoad {
    [super viewDidLoad];
    instance = self;
    // Do any additional setup after loading the view.
    _views = @[@"Dining", @"Directory", @"Courses", @"Maps", @"Transit", @"theDP", @"UTB", @"34th St", @"Events@Penn", @"About", @"Support"];
    UITapGestureRecognizer *labsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLabsURL:)];
    [_labsImage addGestureRecognizer:labsTap];
    UISwipeGestureRecognizer *returnSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(returnToView:)];
    returnSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:returnSwipe];
}
- (IBAction)returnToView:(id)sender {
    [self performSegueWithIdentifier:currentView sender:self];
}
- (void)showLabsURL:(id)sender {
    // open labs URL here
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated {
    _menuOut = YES;
}
- (void)viewDidDisappear:(BOOL)animated {
    _menuOut = NO;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = _views[indexPath.row];
    UIImage *image = [UIImage imageNamed:title];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:title];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:title];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.tintColor = [UIColor whiteColor];
    cell.imageView.image = image;
    cell.imageView.tintColor = [UIColor whiteColor];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.backgroundColor = [UIColor clearColor];
    if (!start && [title isEqualToString:@"Dining"]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        cell.textLabel.textColor = PENN_BLUE;
        cell.imageView.image = [UIImage imageNamed:[cell.textLabel.text stringByAppendingString:@"-selected"]];
        currentView = cell.textLabel.text;
        start = indexPath;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = PENN_BLUE;
    cell.imageView.image = [UIImage imageNamed:[cell.textLabel.text stringByAppendingString:@"-selected"]];
    currentView = cell.textLabel.text;
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.imageView.image = [UIImage imageNamed:cell.textLabel.text];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _views.count;
}
- (void)returnToView {
    [self performSegueWithIdentifier:currentView sender:self];
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    double animDuration = 0.8;
    
    if (scrollView.contentOffset.y < 0 && scrollView.contentOffset.y <= scrollView.contentSize.height) {
        // scrolled up        
        [UIView beginAnimations:@"fade in" context:nil];
        [UIView setAnimationDuration:animDuration];
        _labsImage.alpha = 1.0;
        [UIView commitAnimations];
    } else if (scrollView.contentOffset.y > 0) {
        // scrolled down
        [UIView beginAnimations:@"fade out" context:nil];
        [UIView setAnimationDuration:animDuration];
        _labsImage.alpha = 0.0;
        [UIView commitAnimations];
    } else if (scrollView.contentOffset.y == 0) {
        [UIView beginAnimations:@"fade in" context:nil];
        [UIView setAnimationDuration:animDuration/2];
        _labsImage.alpha = 1.0;
        [UIView commitAnimations];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // stopped scrolling
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // stopped scrolling
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    PennNavController *nav = segue.destinationViewController;
    if (/* nav.grayedOut */ false) {
        [[[nav.view subviews] objectAtIndex:0] removeFromSuperview];
        nav.grayedOut = NO;
    }
    NewsViewController *t = ((UINavigationController *)nav).viewControllers[0];
    if ([segue.identifier isEqualToString:@"theDP"]) {
        [t setUrl:@"http://www.thedp.com/"];
    } else if ([segue.identifier isEqualToString:@"UTB"]) {
        [t setUrl:@"http://www.thedp.com/blog/under-the-button"];
    } else if ([segue.identifier isEqualToString:@"Events@Penn"]) {
        [t setUrl:@"http://eventsatpenn.com/"];
    } else if ([segue.identifier isEqualToString:@"34th St"]) {
        [t setUrl:@"http://www.34st.com/"];
    }

}


@end

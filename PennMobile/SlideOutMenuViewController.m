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

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue { }

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _views = @[@"Dining", @"Directory", @"Registrar", @"Transit", @"News", @"About"];
    UITapGestureRecognizer *labsTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLabsURL:)];
    [_labsImage addGestureRecognizer:labsTap];
    UISwipeGestureRecognizer *returnSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(returnToView:)];
    returnSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:returnSwipe];
}
- (void)returnToView:(id)sender {
    [self performSegueWithIdentifier:currentView sender:self];
}
- (void)showLabsURL:(id)sender {
    // open labs URL here
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = _views[indexPath.row];
    UIImage *image = [UIImage imageNamed:title];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:title];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:title];
    }
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
}


@end

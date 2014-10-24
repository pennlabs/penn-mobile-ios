//
//  DetailViewController.m
//  PennMobile
//
//  Created by Sacha Best on 10/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

static MKLocalSearchRequest *req;
static MKLocalSearch *search;

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configureUsingCover:(id)cover title:(NSString *)title sub:(NSString *)sub detail:(NSString *)detail {
    if ([cover isKindOfClass:[UIImage class]]) {
        UIImage *coverImage = cover;
        _mapCover.hidden = YES;
        _imageCover.hidden = NO;
        _imageCover.image = coverImage;
        _imageCover.contentMode = UIViewContentModeScaleAspectFill;
        _titleText.text = title;
        _detailText.text = detail;
        if (sub)
            _subText.text = sub;
        
    } else if ([cover isKindOfClass:[NSString class]]) {
        [DetailViewController searchForBuilding:cover sender:self completion:@selector(setupMap:)];
        _mapCover.hidden = NO;
        _imageCover.hidden = YES;
        _titleText.text = title;
        _detailText.text = detail;
        if (sub)
            _subText.text = sub;
    } else {
        [NSException raise:@"Invalid DetailView Configuation" format:@"Type %@ passed. Expecting MKMapItem or UIImage.", [cover class]];
    }
}
- (void)setupMap:(MKMapItem *)point {
    [_mapCover setCenterCoordinate:point.placemark.coordinate animated:NO];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

+ (void)searchForBuilding:(NSString *)query sender:(id)sender completion:(SEL)completion {
    if (!req) {
        req = [[MKLocalSearchRequest alloc] init];
        req.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(39.952219, -75.193214), MKCoordinateSpanMake(10, 10));
    }
    req.naturalLanguageQuery = query;
    search = [[MKLocalSearch alloc] initWithRequest:req];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (response.mapItems.count > 0)
            [sender performSelector:completion withObject:response.mapItems[0]];
    }];
}
@end

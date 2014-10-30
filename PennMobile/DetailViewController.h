//
//  DetailViewController.h
//  PennMobile
//
//  Created by Sacha Best on 10/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailViewController : UIViewController {
    NSString *titleText;
    NSString *subText;
    NSString *detailText;
    UIImage *coverUIImage;
    MKMapItem *center;
}

@property (weak, nonatomic) IBOutlet UIVisualEffectView *viewTitle;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UILabel*subText;
@property (weak, nonatomic) IBOutlet UIImageView *imageCover;
@property (weak, nonatomic) IBOutlet MKMapView *mapCover;
@property (weak, nonatomic) IBOutlet UITextView *detailText;

-(void)configureUsingCover:(id)cover title:(NSString *)title sub:(NSString *)sub detail:(NSString *)detail;

+(void)searchForBuilding:(NSString *)query sender:(id)sender completion:(SEL)completion;
@end

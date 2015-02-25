//
//  DetailViewController.h
//  PennMobile
//
//  Created by Sacha Best on 10/23/14.
//  Copyright (c) 2014 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Course.h"
#import "Building.h"

#define kMapSize 800

@interface DetailViewController : UIViewController <CLLocationManagerDelegate> {
    UIImage *coverUIImage;
    MKMapItem *center;
    CLLocationManager *locationManager;
    Course *info;
    Building *building;
}

@property (weak, nonatomic) IBOutlet UIButton *buttonRoute;
@property (weak, nonatomic) IBOutlet UILabel *noLoc;
@property (weak, nonatomic) IBOutlet UILabel *labelTime;

@property (weak, nonatomic) IBOutlet UILabel *labelNoLoc;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *viewTitle;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UILabel *subText;
@property (weak, nonatomic) IBOutlet UILabel *credits;
@property (weak, nonatomic) IBOutlet UILabel *courseNumber;
@property (weak, nonatomic) IBOutlet UILabel *sectionNum;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageCover;
@property (weak, nonatomic) IBOutlet MKMapView *mapCover;
@property (weak, nonatomic) IBOutlet UITextView *detailText;

-(void)configureUsingCover:(id)cover title:(NSString *)title sub:(NSString *)sub number:(NSString *)num credits:(NSString *)credits detail:(NSString *)detail;
-(IBAction)back:(id)sender;
-(IBAction)route:(id)sender;
+(void)searchForBuilding:(NSString *)query sender:(id)sender completion:(SEL)completion;
-(void)configureWithCourse:(Course *)course;
-(void)configureUsingBuilding:(Building *)bldg;

@end

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

}

@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *subText;
@property (weak, nonatomic) IBOutlet UIImageView *imageCover;
@property (weak, nonatomic) IBOutlet MKMapView *mapCover;
@property (weak, nonatomic) IBOutlet UITextView *detailText;

-(void)configureUsingCover:(id)cover title:(NSString *)title sub:(NSString *)sub detail:(NSString *)detail;

+(void)searchForBuilding:(NSString *)query sender:(id)sender completion:(SEL)completion;
@end

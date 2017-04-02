//
//  DirectionView.h
//  PennMobile
//
//  Created by Sacha Best on 3/24/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import <UIKit/UIKit.h>

#define VIEW_HEIGHT 88.0f
#define TITLE_FONT [UIFont fontWithName:@"Helvetica Neue" size:20.0f]
#define TITLE_HEIGHT 22.0f
#define SUBTITLE_HEIGHT 18.0f
#define SUBTITLE_FONT [UIFont fontWithName:@"Helvetica Neue" size:16.0f]
#define ARROW_WIDTH 10.0f
#define ARROW_HEIGHT 25.0f

@interface DirectionView : UIView

@property (weak, nonatomic) UILabel *title;
@property (weak, nonatomic) UILabel *distance;

+ (DirectionView *)make:(NSString *)name distance:(double)dist routeTitle:(NSString *)bus isLast:(bool)last;

+ (CGSize)size;
@end

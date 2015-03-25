//
//  DirectionView.m
//  PennMobile
//
//  Created by Sacha Best on 3/24/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "DirectionView.h"

#define VIEW_HEIGHT 88.0f
#define TITLE_FONT [UIFont fontWithName:@"temp" size:20.0f]
#define TITLE_HEIGHT 22.0f
#define SUBTITLE_HEIGHT 18.0f
#define SUBTITLE_FONT [UIFont fontWithName:@"temp" size:16.0f]
#define ARROW_WIDTH 10.0f
#define ARROW_HEIGHT 25.0f

@implementation DirectionView

static float screenWidth = 0;

+ (DirectionView *)forWalk:(NSString *)name distance:(double)dist isLast:(bool)last {
    if (screenWidth == 0) {
        screenWidth = [[UIScreen mainScreen] bounds].size.width;
    }
    DirectionView *n = [[DirectionView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, VIEW_HEIGHT) ];
    n.backgroundColor = PENN_RED;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(25, (VIEW_HEIGHT - TITLE_HEIGHT) / 2.0, screenWidth - 50, TITLE_HEIGHT)];
    title.text = name;
    [n setTitle:title];
    [n addSubview:title];
    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(35, (VIEW_HEIGHT - TITLE_HEIGHT - SUBTITLE_HEIGHT) / 2.0, screenWidth - 70, SUBTITLE_HEIGHT)];
    subtitle.text = [NSString stringWithFormat:@"walk %.2fmi to", round(dist)];
    [n setDistance:subtitle];
    [n addSubview:subtitle];
    if (!last) {
        [n addSubview:[DirectionView makeArrow]];
    }
    return n;
}

+ (UIImageView *)makeArrow {
    UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow"]];
    arrow.frame = CGRectMake(screenWidth - 10 - (ARROW_WIDTH / 2.0), (VIEW_HEIGHT - ARROW_HEIGHT) / 2.0,ARROW_WIDTH, ARROW_HEIGHT);
    return arrow;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  DirectionView.m
//  PennMobile
//
//  Created by Sacha Best on 3/24/15.
//  Copyright (c) 2015 PennLabs. All rights reserved.
//

#import "DirectionView.h"


@implementation DirectionView

static float screenWidth = 0;
static int numCreated = 0;

+ (DirectionView *)make:(NSString *)name distance:(double)dist isBus:(bool)bus isLast:(bool)last {
    if (screenWidth == 0) {
        screenWidth = [[UIScreen mainScreen] bounds].size.width;
    }
    DirectionView *n = [[DirectionView alloc] initWithFrame:CGRectMake(numCreated * screenWidth, 0, screenWidth, VIEW_HEIGHT) ];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(25, (VIEW_HEIGHT - TITLE_HEIGHT) / 2.0, screenWidth - 50, TITLE_HEIGHT)];
    title.text = name;
    title.font = TITLE_FONT;
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    [n setTitle:title];
    [n addSubview:title];
    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(35, (VIEW_HEIGHT - TITLE_HEIGHT - SUBTITLE_HEIGHT - 30) / 2.0, screenWidth - 70, SUBTITLE_HEIGHT)];
    if (bus) {
        n.backgroundColor = PENN_BLUE;
        // subtitle.text = [NSString stringWithFormat:@"bus %.2fmi to", round(dist)];
    } else {
        n.backgroundColor = PENN_RED;
        subtitle.font = SUBTITLE_FONT;
        subtitle.text = [NSString stringWithFormat:@"walk %.2fmi to", round(dist)];
        subtitle.textColor = [UIColor whiteColor];
        subtitle.textAlignment = NSTextAlignmentCenter;
    }
    [n setDistance:subtitle];
    [n addSubview:subtitle];
    if (!last) {
        [n addSubview:[DirectionView makeArrow]];
    }
    numCreated += 1;
    numCreated %= 3;
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

+ (CGSize)size {
    if (screenWidth == 0) {
        screenWidth = [[UIScreen mainScreen] bounds].size.width;
    }
    return CGSizeMake(3 * screenWidth, VIEW_HEIGHT);
}

@end

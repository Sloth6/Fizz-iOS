//
//  BCNBubbleView.m
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNBubbleView.h"

@implementation BCNBubbleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (int i = 0; i < [[self subviews] count]; ++i){
        UIView *subview = [[self subviews] objectAtIndex:i];
        
        if ([subview pointInside:point withEvent:event]){
            return YES;
        }
    }
    
    // UIView will be "transparent" for touch events if we return NO
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

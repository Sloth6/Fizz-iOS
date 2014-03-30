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
        
        float minX = subview.frame.origin.x;
        float minY = subview.frame.origin.y;
        
        float width = subview.frame.size.width;
        
        float radius = width / 2.0;
        
        float x = minX + radius;
        float y = minY + radius;
        
        // a^2 + b^2 <= c^2
        CGFloat xDist = (x - point.x);
        CGFloat yDist = (y - point.y);
        CGFloat distance = sqrt((xDist * xDist) + (yDist * yDist));
        
        if (distance <= radius){
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

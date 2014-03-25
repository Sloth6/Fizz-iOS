//
//  BCNNavButton.m
//  Fizz
//
//  Created by Andrew Sweet on 3/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNNavButton.h"

static float kGrayscale = 0.6;
static float kAlpha = 1.0;

@interface BCNNavButton ()

@property ButtonState buttonState;

@end

@implementation BCNNavButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setState:(ButtonState)state{
    _buttonState = state;
    
    [self setNeedsDisplay];
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    float minX = self.frame.origin.x;
    float minY = self.frame.origin.y;
    
    float maxX = minX + self.frame.size.width;
    float maxY = minY + self.frame.size.height;
    
    if (point.x < maxX && point.y < maxY &&
        point.x > minX && point.y > minY){
        return YES;
    }
    
    return NO;
}

/*- (void)drawExpandedForRect:(CGRect)rect{
    // Get the current graphics context
    // (ie. where the drawing should appear)
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the width of the line
    CGContextSetLineWidth(context, 1.0);
    
    float spacing = 12;
    float halfSpace = spacing/2;
    
    float height = rect.size.height;
    float midY = height/2;
    
    float width = rect.size.width;
    
    CGContextBeginPath(context);
    
    // Top Line
    CGContextMoveToPoint(context, 0, midY - halfSpace);
    CGContextAddLineToPoint(context, width, midY - halfSpace);
    
    // Bottom Line
    CGContextMoveToPoint(context, 0, midY + halfSpace);
    CGContextAddLineToPoint(context, width, midY + halfSpace);
    
    CGContextClosePath(context);
    
    CGContextSetRGBStrokeColor(context, kGrayscale, kGrayscale, kGrayscale, kAlpha);
    
    // Draw Path
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawCollapsedForRect:(CGRect)rect{
    
}

- (void)drawCancelForRect:(CGRect)rect{
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    switch (_buttonState) {
        case kExpanded:
        {
            
        }
            break;
            
        case kCollapsed:
        {
            
        }
            break;
            
        case kCancel:
        {
            
        }
            break;
            
        default:
            break;
    }
}*/


@end

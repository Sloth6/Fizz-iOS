//
//  FZZInviteGuestButton.m
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInviteGuestButton.h"

static const float kGrayscale = 0.6;
static const float kAlpha = 1.0;

@implementation FZZInviteGuestButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Get the current graphics context
    // (ie. where the drawing should appear)
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the width of the line
    CGContextSetLineWidth(context, 1.0);
    
    float radius = (self.bounds.size.width/2.0) - 2;
    
    float plusLength = (1.0/3.0) * self.bounds.size.width;
    
    CGContextBeginPath(context);
    
    // Circle
    CGContextAddArc(context, radius, radius, radius - 2, 0, 2*M_PI, YES);
    
    // Horizontal Line
    CGContextMoveToPoint(context, radius, radius - (plusLength/2.0));
    CGContextAddLineToPoint(context, radius, radius + (plusLength/2.0));
    
    // Vertical Line
    CGContextMoveToPoint(context, radius - (plusLength/2.0), radius);
    CGContextAddLineToPoint(context, radius + (plusLength/2.0), radius);

    
    CGContextClosePath(context);
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(context, kGrayscale, kGrayscale, kGrayscale, kAlpha);
    
    // Draw Path
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

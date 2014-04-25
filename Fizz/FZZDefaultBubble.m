//
//  FZZDefaultBubble.m
//  Fizz
//
//  Created by Andrew Sweet on 3/26/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZDefaultBubble.h"

@interface FZZDefaultBubble ()


@end

@implementation FZZDefaultBubble

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor redColor]];
    }
    
    return self;
}

//- (void)drawRect:(CGRect)rect
//{
//    // Get the current graphics context
//    // (ie. where the drawing should appear)
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    // Set the width of the line
////    CGContextSetLineWidth(context, 1.0);
//    
//    float radius = (self.bounds.size.width/2.0) - 2;
//    
//    CGContextBeginPath(context);
//    
//    // Circle
//    
//    CGContextAddArc(context, radius + 1, radius + 1, radius, 0, 2 * M_PI, YES);
//    
//    CGContextClosePath(context);
//    
//    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
//    
//    // Draw Path
//    CGContextDrawPath(context, kCGPathFill);
//    
//    [self drawTextInRect:rect];
//}

- (UIImage *)imageFromBubble{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end

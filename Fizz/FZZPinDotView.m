//
//  FZZPinDotView.m
//  Fizz
//
//  Created by Andrew Sweet on 8/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZPinDotView.h"

#import "FZZUtilities.h"

@implementation FZZPinDotView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawDot];
}

- (void)drawDot{
    CGFloat diameter = 8;
    CGFloat howFarDown = 1.0 / 2.0;
    
    CGFloat x = ((self.frame.size.width - self.frame.origin.x)/2) - (diameter/2);
    CGFloat y = ((self.frame.size.height - self.frame.origin.y)*howFarDown) - (diameter/2);
    
    CGRect rect = CGRectMake(x, y, diameter, diameter);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *whiteColor = kFZZWhiteTextColor();
    
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
    
    [whiteColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    CGFloat colorComponents[4] = {red, green, blue, alpha};
    
    CGContextSetStrokeColorWithColor(context, [kFZZWhiteTextColor() CGColor]);
    CGContextSetFillColor(context, colorComponents);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextFillPath(context);
}

@end

//
//  BCNSpeechBubble.m
//  Beacon
//
//  Created by Andrew Sweet on 1/6/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNSpeechBubble.h"

@interface BCNSpeechBubble ()

@property UILabel *message;

@end

VerticalAlignment vAlign;
HorizontalAlignment hAlign;

@implementation BCNSpeechBubble

@synthesize message;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 5.0;
        vAlign = top;
        hAlign = left;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, .5f);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    
    //[viewMessage sizeToFit]
    
    NSString *string;
    
    CGSize size = [string sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}];
    
    CGRect rrect = CGRectMake(0, 0, size.width, size.height);
    
    //CGRect rrect = message.frame;
    rrect.origin.y++;
    CGFloat radius = self.layer.cornerRadius;
    
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    CGMutablePathRef outlinePath = CGPathCreateMutable();
    
    if (left){
        minx += 5;
        
        CGPathMoveToPoint(outlinePath, nil, midx, miny);
        CGPathAddArcToPoint(outlinePath, nil, maxx, miny, maxx, midy, radius);
        CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, midx, maxy, radius);
        
        if (bottom){
            CGPathAddLineToPoint(outlinePath, nil, minx - 5, maxy);
            CGPathAddArcToPoint(outlinePath, nil, minx, maxy, minx, maxy - 5, radius);
            CGPathAddArcToPoint(outlinePath, nil, minx, miny, midx, miny, radius);
        } else if (top){
            CGPathAddArcToPoint(outlinePath, nil, minx, maxy, minx, midy, radius);
            CGPathAddLineToPoint(outlinePath, nil, minx, miny + 5);
            CGPathAddArcToPoint(outlinePath, nil, minx, miny, minx - 5, miny, radius);
            CGPathAddLineToPoint(outlinePath, nil, midx, miny);
        } else {
            CGPathAddArcToPoint(outlinePath, nil, minx, maxy, minx, midy + 2.5, radius);
            CGPathAddLineToPoint(outlinePath, nil, minx - 5, midy);
            CGPathAddLineToPoint(outlinePath, nil, minx, midy - 2.5);
            CGPathAddArcToPoint(outlinePath, nil, minx, miny, midx, miny, radius);
        }
    } else if (right){
        maxx -= 5;
        
        CGPathMoveToPoint(outlinePath, nil, midx, miny);
        
        if (top){
            CGPathAddLineToPoint(outlinePath, nil, maxx + 5, miny);
            CGPathAddArcToPoint(outlinePath, nil, maxx, miny, maxx, miny + 5, radius);
            CGPathAddLineToPoint(outlinePath, nil, maxx, midy);
            CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, midx, maxy, radius);
        } else if (bottom){
            CGPathAddArcToPoint(outlinePath, nil, maxx, miny, maxx, midy, radius);
            CGPathAddLineToPoint(outlinePath, nil, maxx, maxy - 5);
            CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, maxx + 5, maxy, radius);
            CGPathAddLineToPoint(outlinePath, nil, midx, maxy);
        } else {
            CGPathAddArcToPoint(outlinePath, nil, maxx, miny, maxx, midy - 2.5, radius);
            CGPathAddLineToPoint(outlinePath, nil, maxx + 5, midy);
            CGPathAddLineToPoint(outlinePath, nil, maxx, midy + 2.5);
            CGPathAddArcToPoint(outlinePath, nil, maxx, maxy, midx, maxy, radius);
        }
        
        CGPathAddArcToPoint(outlinePath, nil, minx, maxy, minx, midy, radius);
        CGPathAddArcToPoint(outlinePath, nil, minx, miny, midx, miny, radius);
    }
    
    CGContextSetShadowWithColor(context, CGSizeMake(0,1), 1, [UIColor lightGrayColor].CGColor);
    CGContextAddPath(context, outlinePath);
    CGContextFillPath(context);
    
    CGContextAddPath(context, outlinePath);
    CGContextClip(context);
    CGPoint start = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint end = CGPointMake(rect.origin.x, rect.size.height);
    CGContextDrawLinearGradient(context, [self normalGradient], start, end, 0);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (CGGradientRef)normalGradient
{
    
    NSMutableArray *normalGradientLocations = [NSMutableArray arrayWithObjects:
                                               [NSNumber numberWithFloat:0.0f],
                                               [NSNumber numberWithFloat:1.0f],
                                               nil];
    
    
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:2];
    
    UIColor *color = [UIColor whiteColor];
    [colors addObject:(id)[color CGColor]];
    color = [UIColor lightGrayColor];//[StyleView lightColorFromColor:[UIColor cloudsColor]];
    [colors addObject:(id)[color CGColor]];
    NSMutableArray  *normalGradientColors = colors;
    
    int locCount = [normalGradientLocations count];
    CGFloat locations[locCount];
    for (int i = 0; i < [normalGradientLocations count]; i++)
    {
        NSNumber *location = [normalGradientLocations objectAtIndex:i];
        locations[i] = [location floatValue];
    }
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef normalGradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)normalGradientColors, locations);
    CGColorSpaceRelease(space);
    
    return normalGradient;
}

@end

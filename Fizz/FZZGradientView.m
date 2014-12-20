//
//  FZZGradientView.m
//  Let's
//
//  Created by Andrew Sweet on 12/19/14.
//  Copyright (c) 2014 Off Brand. All rights reserved.
//

#import "FZZGradientView.h"

@implementation FZZGradientView

@synthesize gradient;

- (id)initWithGradient:(CGGradientRef)grad {
    self = [super init];
    if(self){
        [self setGradient:grad];
    }
    return self;
}

- (id)initWithColor:(UIColor*)top bottom:(UIColor*)bot {
    self = [super init];
    if(self){
        [self setGradientWithColor:top bottom:bot];
    }
    return self;
}

- (void)setGradient:(CGGradientRef)g {
    if(gradient != NULL && g != gradient){
        CGGradientRelease(gradient);
    }
    if(g != gradient){
        CGGradientRetain(g);
    }
    gradient = g;
    [self setNeedsDisplay];
}

- (void)setGradientWithColor:(UIColor*)top bottom:(UIColor*)bot {
    NSArray *colors = [NSArray arrayWithObjects:(id)top.CGColor, (id)bot.CGColor, nil];
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef grad = CGGradientCreateWithColors(space, (CFArrayRef)colors, NULL);
    
//    [top getRGBA:clr];
//    [bot getRGBA:clr+4] ;
//    CGGradientRef grad = CGGradientCreateWithColorComponents(rgb, clr, NULL, sizeof(clr)/(sizeof(clr[0])*4));
    [self setGradient:grad];
    CGColorSpaceRelease(space);
    CGGradientRelease(grad);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(c, gradient, CGPointMake(0, 0), CGPointMake(0, rect.size.height), 0);
}


- (void)dealloc {
    CGGradientRelease(gradient);
}


@end
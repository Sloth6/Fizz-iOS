//
//  FZZGradientView.h
//  Let's
//
//  Created by Andrew Sweet on 12/19/14.
//  Copyright (c) 2014 Off Brand. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZGradientView : UIView {
    CGGradientRef gradient;
}

@property(nonatomic, assign) CGGradientRef gradient;

- (id)initWithGradient:(CGGradientRef)gradient;
- (id)initWithColor:(UIColor*)top bottom:(UIColor*)bot;
- (void)setGradientWithColor:(UIColor*)top bottom:(UIColor*)bot;

@end
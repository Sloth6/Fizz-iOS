//
//  BCNNavigationBar.m
//  Fizz
//
//  Created by Andrew Sweet on 3/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNNavigationBar.h"

@implementation BCNNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setupBackground];
}

- (void)setupBackground {
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor clearColor];
    
    // make navigation bar overlap the content
    self.translucent = YES;
    self.opaque = NO;
    
    // remove the default background image by replacing it with a clear image
    [self setBackgroundImage:[self.class maskedImage] forBarMetrics:UIBarMetricsDefault];
    
    // remove defualt bottom shadow
    [self setShadowImage: [UIImage new]];
}

+ (UIImage *)maskedImage {
    const float colorMask[6] = {222, 255, 222, 255, 222, 255};
    
    UIImage *img = [UIImage imageNamed:@"nav-white-pixel-bg.jpg"];
    
    return [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(img.CGImage, colorMask)];
}

@end

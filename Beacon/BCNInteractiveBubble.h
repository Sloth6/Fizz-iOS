//
//  BCNInteractiveBubble.h
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCNBubbleViewController.h"

@interface BCNInteractiveBubble : UIView

-(void)setIsEmpty:(BOOL)isEmpty;
-(void)setImageView:(UIImageView *)imageView;
-(void)setCenter:(CGPoint)center;

@end

//
//  FZZInteractiveBubble.h
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZZBubbleViewController.h"

/* 
 
 These are the floating faces. They can be toggleable as interactive, they can act as a button, and can be thrown off screen given the logic allows the given user to within the FZZBubbleViewController.
 
 */

@class FZZUser;

@interface FZZInteractiveBubble : UIView

-(void)setIsEmpty:(BOOL)isEmpty;
-(void)setImageView:(UIImageView *)imageView;
-(void)setCenter:(CGPoint)center;

@property FZZUser *user;

@end

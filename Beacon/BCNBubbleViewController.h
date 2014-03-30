//
//  BCNBubbleViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCNInteractiveBubble;
@class BCNBubbleView;
@class BCNEvent;

@interface BCNBubbleViewController : UIViewController

@property BCNBubbleView *bubbleView;

- (void)updateBubblesForEvent:(BCNEvent *)event
                      AtIndex:(NSIndexPath *)indexPath
                     Animated:(BOOL)isAnimated;

- (void)updateBubblesForEvent:(BCNEvent *)event
                     Animated:(BOOL)isAnimated;

- (void)transitionToEvent:(BCNEvent *)event
                  AtIndex:(NSIndexPath *)indexPath;

- (void)trashBubble:(BCNInteractiveBubble *)bubble;

@end

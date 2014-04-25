//
//  FZZBubbleViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZInteractiveBubble;
@class FZZBubbleView;
@class FZZEvent;

@interface FZZBubbleViewController : UIViewController

@property FZZBubbleView *bubbleView;

- (FZZEvent *)event;

- (void)updateBubblesForEvent:(FZZEvent *)event
                      AtIndex:(NSIndexPath *)indexPath
                     Animated:(BOOL)isAnimated;

- (void)updateBubblesForEvent:(FZZEvent *)event
                     Animated:(BOOL)isAnimated;

- (void)transitionToEvent:(FZZEvent *)event
                  AtIndex:(NSIndexPath *)indexPath;

- (void)trashBubble:(FZZInteractiveBubble *)bubble;


-(void)viewDidScroll:(UIScrollView *)scrollView;

@end

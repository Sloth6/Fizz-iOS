//
//  FZZBubbleViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 This UIViewController acts as a delegate for the FZZInteractiveBubbles. It makes sure that if you don't throw a bubble with enough velocity, then you won't throw it. It ensures the bubbles return to where the belong if you simply let go of them. It also makes sure a user has the permissions to throw away a bubble if they didn't  in the first place.
 
 We'll be making a lot of changes to how bubbles work, so I imagine not all of this code will survive to the MVP. It was designed for the seat use-case, but will also handle any logic you want to have with users throwing/moving bubbles.
 
 [TODOAndrew (5/13/14)] Consider shifting the bubble Press logic into the BVC, as that makes more sense from a delegation point of view.
 
 */

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

//- (void)trashBubble:(FZZInteractiveBubble *)bubble;


-(void)viewDidScroll:(UIScrollView *)scrollView;

@end

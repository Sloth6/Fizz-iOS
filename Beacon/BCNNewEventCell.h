//
//  BCNNewEventCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCNInviteViewController;
@class BCNEvent;
@class BCNBackspaceResignTextView;

@interface BCNNewEventCell : UICollectionViewCell <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property BCNBackspaceResignTextView *textView;
@property float lineHeight;
@property UISwitch *toggleSecret;
@property UILabel *label;

@property BCNInviteViewController *ivc;

- (void)scrollToTopAnimated:(BOOL)isAnimated;
- (void)setScrollingEnabled:(BOOL)canScroll;
- (void)sendInvitations;

- (void)setupToggle;
- (void)setupCellWithEvent:(BCNEvent *)event;

@end

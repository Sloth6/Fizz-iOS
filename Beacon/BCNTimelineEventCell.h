//
//  BCNTimelineEventCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/19/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCNInviteViewController;
@class BCNEvent;

@interface BCNTimelineEventCell : UICollectionViewCell <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property UITextView *textView;
@property float lineHeight;

@property BCNInviteViewController *ivc;

- (void)setScrollingEnabled:(BOOL)canScroll;
- (void)sendInvitations;

- (void)setupCellWithEvent:(BCNEvent *)event;

@end

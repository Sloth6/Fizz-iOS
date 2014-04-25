//
//  FZZTimelineEventCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/19/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZInviteViewController;
@class FZZEvent;

@interface FZZTimelineEventCell : UICollectionViewCell <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property UITextView *textView;
@property float lineHeight;

@property FZZInviteViewController *ivc;

- (void)setScrollingEnabled:(BOOL)canScroll;
- (void)sendInvitations;

- (void)setupCellWithEvent:(FZZEvent *)event;

@end

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
@class BCNChatDelegate;

@interface BCNNewEventCell : UICollectionViewCell <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property BCNBackspaceResignTextView *textView;
@property float lineHeight;
@property UISwitch *toggleSecret;
@property UILabel *label;

@property UILabel *attendeesLabel;

@property UILabel *seatsLabel;
@property UIButton *addSeatButton;
@property UIButton *removeSeatButton;

@property UIButton *chatButton;
@property BCNChatDelegate *chatDelegate;

@property BCNInviteViewController *ivc;

- (void)scrollToTopAnimated:(BOOL)isAnimated;
- (void)setScrollingEnabled:(BOOL)canScroll;
- (void)sendInvitations;

- (void)enterInviteMode;
- (void)exitInviteMode;
- (void)enterChatMode;
- (void)exitChatMode;


- (void)setEvent:(BCNEvent *)event;

- (void)updateFriends;

- (void)setupToggle;

@end

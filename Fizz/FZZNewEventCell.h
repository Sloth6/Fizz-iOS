//
//  FZZNewEventCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZInviteViewController;
@class FZZEvent;
@class FZZBackspaceResignTextView;
@class FZZChatDelegate;

@interface FZZNewEventCell : UICollectionViewCell <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property FZZBackspaceResignTextView *resignTextViewer;
@property float lineHeight;
@property UISwitch *toggleSecret;
@property UILabel *label;

@property UILabel *attendeesLabel;

@property UIButton *addSeatButton;

@property FZZChatDelegate *chatDelegate;

@property FZZInviteViewController *ivc;
@property (strong, nonatomic) FZZEvent *event;

- (void)scrollToTopAnimated:(BOOL)isAnimated;
- (void)setScrollingEnabled:(BOOL)canScroll;
- (void)sendInvitations;

- (void)enterInviteMode;
- (void)exitInviteMode;
- (void)enterChatMode;
- (void)exitChatMode;


- (void)setEvent:(FZZEvent *)event;

- (void)updateFriends;

- (void)setupToggle;
- (void)setupNewEventCell;
- (void)setupCell;

@end

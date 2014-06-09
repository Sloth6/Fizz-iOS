//
//  FZZExpandedEventCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 While in the expanded view, each of these cells is what's on display.
 Each cell contains a tableview which scrolls vertically,
 revealing the cell containing the chat view, [TODOAndrew (5/13/14)]
 and the cell containing the invite view. [TODOAndrew (5/13/14)]
 
 [TODOAndrew (5/13/14)] The current implementation does not paginate, they are simply in
 one large scrolling view which locks if you choose to leave the view. Pagination
 is a much simpler and more appropriate approach for the current design.
 
 The scroll is paginated to ensure snapping to and from the appropriate views
 
 */

@class FZZInviteViewController;
@class FZZEvent;
@class FZZChatDelegate;
@class FZZExpandedVerticalTableViewController;

@interface FZZExpandedEventCell : UICollectionViewCell <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property UITextView *textView;
@property float lineHeight;
@property UISwitch *toggleSecret;
@property UILabel *label;

@property UILabel *attendeesLabel;

@property FZZChatDelegate *chatDelegate;

@property FZZExpandedVerticalTableViewController *tvc;
@property FZZInviteViewController *ivc;
@property (strong, nonatomic) FZZEvent *event;

- (void)scrollToTopAnimated:(BOOL)isAnimated;
- (void)setScrollingEnabled:(BOOL)canScroll;
- (void)sendInvitations;

//- (void)enterInviteMode;
//- (void)exitInviteMode;
//- (void)enterChatMode;
//- (void)exitChatMode;

- (void)setEvent:(FZZEvent *)event;

// Update who is currently invited and not invited for the Invite View Controller
- (void)updateFriends;

- (void)setupToggle;
- (void)setupExpandedEventCell;

@end

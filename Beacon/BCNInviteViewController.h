//
//  BCNInviteViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCNEvent;
@class BCNNewEventCell;

@interface BCNInviteViewController : UITableViewController <UITextFieldDelegate>

@property UIView *textView;
@property UITextField *phoneTextField;
@property UIButton *confirmPhoneButton;

@property BCNEvent *event;

@property UIButton *addSeatButton;

@property BCNNewEventCell *eventCell;

@property UIButton *inviteButton;

@property BOOL canBeSelected;

+(void)setupClass;

+(void)updateFriends;
-(void)updateFriends;
-(void)sendInvitations;

-(void)setNeedsUpdateFriends;
-(void)takeBubbleView;

-(void)setupInterface;

@end

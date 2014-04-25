//
//  FZZInviteViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZEvent;
@class FZZNewEventCell;

@interface FZZInviteViewController : UITableViewController <UITextFieldDelegate>//, UISearchDisplayDelegate>

@property UIView *textView;
@property UITextField *searchTextField;
@property UIButton *confirmPhoneButton;

@property FZZEvent *event;

@property UIButton *addSeatButton;

@property FZZNewEventCell *eventCell;

@property UIButton *inviteButton;

@property BOOL canBeSelected;

+(void)setupClass;

+(void)updateFriends;
-(void)updateFriends;
-(void)sendInvitations;
-(void)filterInvitables;
-(void)filterContentForSearchText:(NSString*)searchText;

-(void)setNeedsUpdateFriends;
-(void)takeBubbleView;

-(void)setupInterface;

@end

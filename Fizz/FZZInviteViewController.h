//
//  FZZInviteViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

/*
 
 This TableViewController acts as datasource and delegate to the Invite Table View, where users select who to invite to the current event.
 
 [TODOAndrew (5/13/14)] Currently, there's an instance of the IVC for each event, rather than simply and instance of a tableView. Two improvements could be to make 1 IVC for the entire app and then only 1 Invite Table View for each event, or due to the nature of the interface, we could have 1 Invite Table View and 1 IVC by simply dequeueing the same cell which contains the ivc (which the app may already be doing automatically?). If dequeueing only causes 3 of these guys to be alive in the app at once, then this is not an issue. Just ensure 40 events != 40 IVCs.
 
 */

#import <UIKit/UIKit.h>

@class FZZEvent;
@class FZZExpandedEventCell;

@interface FZZInviteViewController : UITableViewController <UITextFieldDelegate>//, UISearchDisplayDelegate>

@property UIView *textView;
@property UITextField *searchTextField;
@property UIButton *confirmPhoneButton;

@property FZZEvent *event;

@property FZZExpandedEventCell *eventCell;

@property UIButton *inviteButton;

@property BOOL canBeSelected;

+(void)setupClass;

+(void)updateFriends;
-(void)updateFriends;
-(void)sendInvitations;
-(void)filterInvitables;
-(void)filterContentForSearchText:(NSString*)searchText;

-(void)setNeedsUpdateFriends;

-(void)setupInterface;

@end

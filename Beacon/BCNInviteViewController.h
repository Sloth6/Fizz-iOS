//
//  BCNInviteViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCNEvent;

@interface BCNInviteViewController : UITableViewController <UITextFieldDelegate>

@property UITextView *textView;
@property UITextField *phoneTextField;
@property UIButton *confirmPhoneButton;

@property BCNEvent *event;

-(void)updateFriends;
-(void)sendInvitations;

@end

//
//  FZZChatDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 3/21/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZZEvent.h"

/*
 
 The chat delegate acts as a pseudo-TableViewController, both as the data source and delegate for the Chat Table View. Its custom controls were preferable for pushing new messages in on the fly
 
 [TODO (5/13/14)] same as FZZInviteViewController, see if we can reduce the number of these in the app or see if the dequeueing of the cell is already ensuring there's only 1, 2, or maybe 3 of these ever existing in the app.
 
 */

@class FZZEventsExpandedViewController;
@class FZZInviteViewController;

@interface FZZChatDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, retain) UIView *viewForm;
@property (nonatomic, retain) UITextView *chatBox;

@property (strong, nonatomic) FZZEvent *event;
@property (strong, nonatomic) FZZEventsExpandedViewController *esvc;
@property (strong, nonatomic) FZZInviteViewController *ivc;

// For temporary deletion of the chat portion
@property int numSectionsDeleted;

@property (strong, nonatomic) UITableView *tableView;

- (void)setupViewForm;
- (void)setupKeyboard;
- (void)addIncomingMessageForEvent:(FZZEvent *)event;

+ (CGRect)getKeyboardBoundsFromNote:(NSNotification *)note;

//- (void)popView;

@end
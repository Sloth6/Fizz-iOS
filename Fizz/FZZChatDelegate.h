//
//  FZZChatDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 3/21/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZZEvent.h"

@class FZZEventStreamViewController;
@class FZZInviteViewController;

@interface FZZChatDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, retain) UIView *viewForm;
@property (nonatomic, retain) UITextView *chatBox;

@property (strong, nonatomic) FZZEvent *event;
@property (strong, nonatomic) FZZEventStreamViewController *esvc;
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
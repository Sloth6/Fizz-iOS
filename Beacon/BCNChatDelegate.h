//
//  BCNChatDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 3/21/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCNEvent.h"

@class BCNEventStreamViewController;
@class BCNInviteViewController;

@interface BCNChatDelegate : NSObject <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, retain) UIView *viewForm;
@property (nonatomic, retain) UITextView *chatBox;
@property (nonatomic, retain) UIButton *chatButton;

@property (strong, nonatomic) BCNEvent *event;
@property (strong, nonatomic) BCNEventStreamViewController *esvc;
@property (strong, nonatomic) BCNInviteViewController *ivc;

// For temporary deletion of the chat portion
@property int numSectionsDeleted;

@property (strong, nonatomic) UITableView *tableView;

- (void)setupViewForm;
- (void)setupKeyboard;
//- (void)popView;

@end
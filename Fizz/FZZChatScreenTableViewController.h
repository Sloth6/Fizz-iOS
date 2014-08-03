//
//  FZZChatScreenTableViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZEvent;
@class FZZEventsViewController;
@class FZZInviteViewController;
@class FZZExpandedVerticalTableViewController;

@interface FZZChatScreenTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableViewCell *view;

@property (strong, nonatomic) FZZEvent *event;
@property (strong, nonatomic) FZZEventsViewController *esvc;
@property (strong, nonatomic) FZZExpandedVerticalTableViewController *tvc;
@property (strong, nonatomic) UITableView *tableView;

- (void)addIncomingMessageForEvent:(FZZEvent *)event;
- (void)updateMessages;

+ (CGRect)getKeyboardBoundsFromNote:(NSNotification *)note;

-(void) keyboardWillShow:(NSNotification *)note;
-(void) keyboardWillHide:(NSNotification *)note;

-(void)updateTableViewToHeight:(CGFloat)height;


- (id)initWithStyle:(UITableViewStyle)style;

@end

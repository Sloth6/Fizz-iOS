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

@interface FZZChatScreenTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITableViewCell *view;

@property (strong, nonatomic) FZZEventsViewController *esvc;
@property (strong, nonatomic) UITableView *tableView;

- (void)addIncomingMessage;
- (void)updateMessages;

- (void)setEventIndexPath:(NSIndexPath *)indexPath;

+ (CGRect)getKeyboardBoundsFromNote:(NSNotification *)note;

-(void) keyboardWillShow:(NSNotification *)note;
-(void) keyboardWillHide:(NSNotification *)note;

-(void)updateTableViewToHeight:(CGFloat)height;

- (id)initWithStyle:(UITableViewStyle)style;

@end

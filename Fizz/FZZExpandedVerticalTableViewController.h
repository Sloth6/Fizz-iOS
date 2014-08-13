//
//  FZZExpandedVerticalTableViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 5/25/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZEvent;

@interface FZZExpandedVerticalTableViewController : UITableViewController

- (void)updateMessages;
- (void)setEventIndexPath:(NSIndexPath *)indexPath;
@property (strong, nonatomic) FZZEvent *event;

- (UIView *)middleCell;
- (UIView *)bottomCell;

- (void)updateMiddleViewText:(NSString *)text;
- (void)updateBottomView:(UIView *)view;

- (void)reloadChat;

@end

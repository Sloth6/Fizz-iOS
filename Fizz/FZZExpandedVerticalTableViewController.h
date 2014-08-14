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

+ (void)setScrollEnabled:(BOOL)canScroll;

- (void)updateMessages;
- (void)setEventIndexPath:(NSIndexPath *)indexPath;
@property (strong, nonatomic) FZZEvent *event;

- (void)reloadChat;

@end

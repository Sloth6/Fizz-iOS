//
//  FZZContactsTableViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FZZFadedEdgeTableViewController.h"

@class FZZContactSelectionDelegate;

@interface FZZContactsTableViewController : FZZFadedEdgeTableViewController

@property FZZContactSelectionDelegate *invitationDelegate;

- (void)setEventIndexPath:(NSIndexPath *)indexPath;
- (void)setTextField:(UITextField *)textField;

@end

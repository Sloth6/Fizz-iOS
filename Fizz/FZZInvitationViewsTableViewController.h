//
//  FZZInvitationViewsTableViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZInvitationViewsTableViewController : UITableViewController

- (void)setEventIndexPath:(NSIndexPath *)indexPath;
- (void)searchBarTextDidChangeTo:(NSString *)text;

@end

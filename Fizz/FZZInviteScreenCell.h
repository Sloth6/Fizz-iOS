//
//  FZZInviteScreenCell.h
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZInvitationViewsTableViewController;

@interface FZZInviteScreenCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate>


@property FZZInvitationViewsTableViewController *ivtvc;

- (void)setEventIndexPath:(NSIndexPath *)indexPath;

@end

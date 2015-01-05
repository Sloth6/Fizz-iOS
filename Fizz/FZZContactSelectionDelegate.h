//
//  FZZContactSelectionDelegate.h
//  Let's
//
//  Created by Andrew Sweet on 10/5/14.
//  Copyright (c) 2014 Off Brand. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZZUser;

@interface FZZContactSelectionDelegate : NSObject

- (int)numberOfInvitableOptions;
- (NSDictionary *)userOrContactAtIndexPath:(NSIndexPath *)indexPath;

- (void)setEventIndexPath:(NSIndexPath *)eventIndexPath;
- (void)setTextField:(UITextField *)textField;

- (void)setCurrentTableView:(UITableView *)tableView;

- (void)sendInvitations;

+ (void)invalidateInvitables;

- (void)searchChange;

@end

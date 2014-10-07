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

- (BOOL)isContactSelected:(NSDictionary *)contact;
- (BOOL)isUserSelected:(FZZUser *)user;

- (BOOL)userOrContactIsSelected:(NSDictionary *)userOrContact;
- (void)deselectUserOrContact:(NSDictionary *)userOrContact;
- (void)selectUserOrContact:(NSDictionary *)userOrContact;

- (void)setCurrentTableView:(UITableView *)tableView;

+ (void)invalidateInvitables;

@end

//
//  FZZContactSearchDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZZUser;

@interface FZZContactSearchDelegate : NSObject

+ (int)numberOfInvitableOptions;
+ (NSDictionary *)userOrContactAtIndexPath:(NSIndexPath *)indexPath;

+ (void)setEventIndexPath:(NSIndexPath *)eventIndexPath;
+ (void)setTextField:(UITextField *)textField;

+ (void)searchFieldTextChanged;

+ (BOOL)isContactSelected:(NSDictionary *)contact;
+ (BOOL)isUserSelected:(FZZUser *)user;

+ (BOOL)userOrContactIsSelected:(NSDictionary *)userOrContact;
+ (void)deselectUserOrContact:(NSDictionary *)userOrContact;
+ (void)selectUserOrContact:(NSDictionary *)userOrContact;

+ (void)updateFriendsAndContacts;

+ (void)promptForAddressBook;

+ (void)setCurrentTableView:(UITableView *)tableView;

@end

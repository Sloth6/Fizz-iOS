//
//  FZZContactDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FZZUser;

@interface FZZContactDelegate : NSObject

// Any time any event invitations occur, update the recent invitations model
// In hopes of sorting your favorite friends more effectively
+(void)updateRecentInvitedUsers:(NSArray *)invitedFriends
                    andContacts:(NSArray *)invitedContacts;

// Will add any new users you have on the client to the invite list, and will load contacts if contacts haven't been loaded yet while the app was in the foreground
+ (void)updateFriendsAndContacts;

// Use this to choose when to prompt the user for access to the Address Book
+ (void)promptForAddressBook;

+ (NSArray *)usersAndContacts;

@end

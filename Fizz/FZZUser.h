//
//  FZZUser.h
//  Fizz
//
//  Created by Andrew Sweet on 5/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SocketIO.h"

@class FZZCoordinate, FZZEvent, FZZMessage;

/*
 
 The FZZUser is a class which attempts to maintain a set of all cached users the current user has interacted with (with possible LRU eviction written in the future).
 
 Grabbing a user should most often be a call like this:
 
 [FZZUser userWithId:ENTER_FIZZ_USER_ID]
 
 Think of this class and the FZZEvent class as dictionaries where you can access a user in the dictionary if it exists, and if it doesn't yet exist, the user will be inserted and then returned to you. The only exception to this rule is when the server is writing to the FZZUser class or we read users from the local cache.
 
 WithAcknowledge should generally accept a null object. Whatever SocketIOCallback function is passed to that parameter will be called when the socket object is successfully sent. It may actually be when a callback from the server occurs; I believe it to be the first, and so I don't think it's nearly as useful.
 
 */

@interface FZZUser : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * phoneNumber;
@property (nonatomic, strong) NSNumber * userID;

+(BOOL)saveUsersToFile:(NSString *)userURL;
+(void)parseUsersJSONForCache:(NSDictionary *)usersJSON;

-(void)setPhoneNumber:(NSString *)phoneNumber;

+(id)addUserWithUserID:(NSNumber *)uID andName:(NSString *)strName;

+(void)setupUserClass;
+(FZZUser *)userWithUID:(NSNumber *)uID;
+(FZZUser *)currentUser;
+(NSArray *)getUsers;
+(NSArray *)getFriends;

+(void)setMeAs:(FZZUser *)me;
+(FZZUser *)me;

+(void)addFriends:(NSArray *)friends;

+(FZZUser *)parseJSON:(NSDictionary *)userJSON;
-(NSDictionary *)toJson;
+(NSArray *)usersToJSONUsers:(NSArray *)users;

+(NSArray *)parseUserJSONFriendList:(NSArray *)friendListJSON;
+(NSMutableArray *)parseUserJSONList:(NSArray *)userListJSON;

+(NSArray *)getUserIDsFromUsers:(NSArray *)users;
+(NSArray *)getUsersFromUIDs:(NSArray *)UIDs;

@end

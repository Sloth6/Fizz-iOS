//
//  FZZUser.h
//  Fizz
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZZCoordinate.h"
#import "FZZDefaultBubble.h"
#import "SocketIO.h"
#import "FZZDataStore.h"

@interface FZZUser : NSManagedObject

/*
 
 The FZZUser is a class which attempts to maintain a set of all cached users the current user has interacted with (with possible LRU eviction written in the future).
 
 Grabbing a user should most often be a call like this:
 
 [FZZUser userWithId:ENTER_FIZZ_USER_ID]
 
 Think of this class and the FZZEvent class as dictionaries where you can access a user in the dictionary if it exists, and if it doesn't yet exist, the user will be inserted and then returned to you. The only exception to this rule is when the server is writing to the FZZUser class or we read users from the local cache.
 
 WithAcknowledge should generally accept a null object. Whatever SocketIOCallback function is passed to that parameter will be called when the socket object is successfully sent. It may actually be when a callback from the server occurs; I believe it to be the first, and so I don't think it's nearly as useful.
 
 */

-(NSNumber *)userID;
-(NSString *)phoneNumber;
-(NSString *)name;
-(NSNumber *)facebookID;
-(NSString *)initials;

// Use this to get a profile picture
-(void)fetchProfilePictureIfNeededWithCompletionHandler:(void(^)(UIImage *image))handler;

// Only call circularImage inside a fetchProfilePictureIfNeeded call
// Also check if (void(^)(UIImage *image)) is NULL before doing anything
-(UIImageView *)circularImage:(float)scalar;
-(UIImageView *)circularImageForRect:(CGRect)rect;

+(UIImageView *)formatImageViewToCircular:(UIImageView *)imageView
                               withScalar:(float)scalar;

-(UIImageView *)formatImageView:(UIImageView *)imageView
          ForInitialsWithScalar:(float)scalar;

+(UIImageView *)formatImageViewToCircular:(UIImageView *)imageView
                                  forRect:(CGRect)rect;

-(UIImageView *)formatImageView:(UIImageView *)imageView
             ForInitialsForRect:(CGRect)rect;

-(void)updateCoordinates:(FZZCoordinate *)coord;
-(void)setFacebookID:(NSNumber *)fbID;
-(void)setPhoneNumber:(NSString *)phoneNumber;

// Returns true if user has no fb image OR hasn't fetched the image yet
-(BOOL)hasNoImage;

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

+(void)socketIONewUserLocation:(FZZCoordinate *)coord
                ForUserWithUID:(NSNumber *)uid
               WithAcknowledge:(SocketIOCallback)function;

+(void)socketIOAddFriendsUserArray:(NSArray *)friendList
                   WithAcknowledge:(SocketIOCallback)function;

+(void)socketIORemoveFriendsUserArray:(NSArray *)friendList
                      WithAcknowledge:(SocketIOCallback)function;

@end

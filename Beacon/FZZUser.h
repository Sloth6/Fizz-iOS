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


@interface FZZUser : NSObject

-(NSNumber *)userID;
-(NSNumber *)facebookID;
-(NSString *)phoneNumber;
-(NSString *)name;
-(NSString *)initials;
-(NSString *)userType;

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
+(NSArray *)getBlackList;

+(void)setMeAs:(FZZUser *)me;
+(FZZUser *)me;

+(void)addFriends:(NSArray *)friends;

+(FZZUser *)parseJSON:(NSDictionary *)userJSON;
-(NSDictionary *)toJson;
+(NSArray *)usersToJSONUsers:(NSArray *)users;

+(NSArray *)parseUserJSONFriendList:(NSArray *)friendListJSON;
+(NSArray *)parseUserJSONBlackList:(NSArray *)blackListJSON;
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

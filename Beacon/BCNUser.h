//
//  BCNUser.h
//  Beacon
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCNCoordinate.h"
#import "SocketIO.h"


@interface BCNUser : NSObject

-(NSNumber *)userID;
-(NSNumber *)facebookID;
-(NSString *)phoneNumber;
-(NSString *)name;
-(NSString *)userType;

// Use this to get a profile picture
-(void)fetchProfilePictureIfNeededWithCompletionHandler:(void(^)(UIImage *image))handler;

// Only call circularImage inside a fetchProfilePictureIfNeeded call
// Also check if (void(^)(UIImage *image)) is NULL before doing anything
-(UIImageView *)circularImage:(float)scalar;

+(UIImageView *)formatImageViewToCircular:(UIImageView *)imageView
                               withScalar:(float)scalar;

-(void)updateCoordinates:(BCNCoordinate *)coord;
-(void)setFacebookID:(NSNumber *)fbID;
-(void)setPhoneNumber:(NSString *)phoneNumber;

+(id)addUserWithUserID:(NSNumber *)uID andName:(NSString *)strName;

+(void)setupUserClass;
+(BCNUser *)userWithUID:(NSNumber *)uID;
+(BCNUser *)currentUser;
+(NSArray *)getUsers;
+(NSArray *)getFriends;

+(BCNUser *)parseJSON:(NSDictionary *)userJSON;

+(NSArray *)parseUserJSONList:(NSArray *)friendListJSON;

+(NSArray *)getUserIDsFromUsers:(NSArray *)users;

+(void)socketIONewUserLocation:(BCNCoordinate *)coord
                ForUserWithUID:(NSNumber *)uid
               WithAcknowledge:(SocketIOCallback)function;

+(void)socketIOAddFriendsUserArray:(NSArray *)friendList
                   WithAcknowledge:(SocketIOCallback)function;

+(void)socketIORemoveFriendsUserArray:(NSArray *)friendList
                      WithAcknowledge:(SocketIOCallback)function;

@end

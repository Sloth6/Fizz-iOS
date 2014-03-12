//
//  BCNFriendList.m
//  Beacon
//
//  Created by Andrew Sweet on 1/25/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNFriendList.h"
#import "BCNUser.h"

static NSString *BCN_GET_FRIEND_LIST = @"getFriendList";

@interface BCNFriendList ()

@property (strong, nonatomic) BCNUser *user;
@property (strong, nonatomic) NSDate *lastUpdate;
@property (strong, nonatomic) NSMutableArray *friends;

@end

@implementation BCNFriendList

- (id)initWithFriends:(NSArray *)friends OfUser: (BCNUser *)user AtLastUpdate: (NSDate *) lastUpdate
{
    self = [super init];
    if (self) {
        _user = user;
        _lastUpdate = lastUpdate;
        _friends = [[NSMutableArray alloc] initWithArray:friends];
    }
    return self;
}

+ (BCNFriendList *)parseJSON:(NSDictionary *)friendListJSON{
    if (friendListJSON == NULL){
        return NULL;
    }
    
    // Person who the friend list belongs to
    NSNumber *uid = [friendListJSON objectForKey:@"of"];
    BCNUser *user = [BCNUser userWithUID:uid];
    
    // Date of last update
    NSNumber *dateAsNum = [friendListJSON objectForKey:@"lastUpdated"];
    NSDate *lastUpdate = [NSDate dateWithTimeIntervalSince1970:[dateAsNum integerValue]];
    
    // List of friends
    NSArray *friends = [friendListJSON objectForKey:@"list"];
    
    BCNFriendList *list = [[BCNFriendList alloc] initWithFriends:friends
                                                          OfUser:user
                                                    AtLastUpdate:lastUpdate];
    
    return list;
}

+(void)socketIOGetFriendsListWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* No parameters */
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_GET_FRIEND_LIST withData:json andAcknowledge:function];
}

@end

//
//  BCNFriendList.h
//  Beacon
//
//  Created by Andrew Sweet on 1/25/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNObject.h"
#import <Foundation/Foundation.h>

@interface BCNFriendList : NSObject

+ (BCNFriendList *)parseJSON:(NSDictionary *)friendListJSON;

+(void)socketIOGetFriendsListWithAcknowledge:(SocketIOCallback)function;

@end

//
//  BCNEvent.h
//  Beacon
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import "BCNObject.h"
#import <CoreLocation/CoreLocation.h>

@class BCNComment;
@class BCNUser;

@interface BCNEvent : NSObject

-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOLeaveEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOInviteWithInviteList:(NSArray *)inviteList
                    InvitePhoneList:(NSArray *)phoneList
                     AndAcknowledge:(SocketIOCallback)function;
-(void)socketIORequestEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOSetSeatCapacityToCapacity:(int)capacity
                         WithAcknowledge:(SocketIOCallback)function;
+(void)socketIONewEventWithMessage:(NSString *)message
                        InviteOnly:(BOOL)isInviteOnly
                    AndAcknowledge:(SocketIOCallback)function;

-(NSNumber *)eventID;

-(BCNUser *)creator;
-(NSArray *)messages;
-(NSArray *)attendees;
-(NSArray *)invitees;
-(NSArray *)engaged;

-(int)numSeats;
-(int)numEmptySeats;

// Most recent new thing, used for sorting
-(NSDate *)lastUpdate;

+(BCNEvent *)eventWithEID:(NSNumber *)eID;
+(void)setupEventClass;

-(void)updateEngaged;

+(BCNEvent *)parseJSON:(NSDictionary *)eventJSON;
+(NSArray *)parseEventJSONList:(NSArray *)eventListJSON;

@end

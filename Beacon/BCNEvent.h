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
@class BCNMessage;

@interface BCNEvent : NSObject

-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOLeaveEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOInviteWithInviteList:(NSArray *)inviteList
                    InviteContactList:(NSArray *)contactList
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

// Attendees is a subset of invitees ALWAYS. People who join a non-secret event are "invited"
-(NSArray *)attendees;
-(NSArray *)invitees;
// invites - attendees
-(NSArray *)notYetAttending;

//-(NSArray *)engaged;
-(BOOL)isInviteOnly;
-(BCNMessage *)firstMessage;

-(BOOL)isInvited:(BCNUser *)user;
-(BOOL)isAttending:(BCNUser *)user;

-(int)pendingNumSeats;
-(int)numSeats;
-(int)pendingNumEmptySeats;
-(int)numEmptySeats;
-(void)addSeat;
-(BOOL)removeSeat;

-(BOOL)expressInterest;
-(BOOL)haveExpressedInterest;
-(BOOL)joinEvent;
-(BOOL)leaveEvent;

-(void)updateInvites:(NSArray *)invites;
-(void)updateRemoveGuest:(BCNUser *)guest;
-(void)updateNumberOfSeats:(NSNumber *)numSeats;
-(void)updateAddMessage:(BCNMessage *)message;
-(void)updateAddGuest:(BCNUser *)guest;

-(BOOL)haveSeatsChangedSinceLastCheck;


// Most recent new thing, used for sorting
-(NSDate *)lastUpdate;

+(BCNEvent *)eventWithEID:(NSNumber *)eID;
+(void)setupEventClass;

//-(void)updateEngaged;

+(BCNEvent *)parseJSON:(NSDictionary *)eventJSON;
+(NSArray *)parseEventJSONList:(NSArray *)eventListJSON;

@end

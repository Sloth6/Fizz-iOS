//
//  FZZEvent.h
//  Fizz
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import "FZZObject.h"
#import <CoreLocation/CoreLocation.h>

@class FZZUser;
@class FZZMessage;

@interface FZZEvent : NSObject

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

-(FZZUser *)creator;
-(NSArray *)messages;

// Attendees is a subset of invitees ALWAYS. People who join a non-secret event are "invited"
-(NSArray *)attendees;
-(NSArray *)invitees;
// invites - attendees
-(NSArray *)notYetAttending;

//-(NSArray *)engaged;
-(BOOL)isInviteOnly;
-(FZZMessage *)firstMessage;

-(BOOL)isInvited:(FZZUser *)user;
-(BOOL)isAttending:(FZZUser *)user;

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
-(void)updateRemoveGuest:(FZZUser *)guest;
-(void)updateNumberOfSeats:(NSNumber *)numSeats;
-(void)updateAddMessage:(FZZMessage *)message;
-(void)updateAddGuest:(FZZUser *)guest;

-(BOOL)haveSeatsChangedSinceLastCheck;


// Most recent new thing, used for sorting
-(NSDate *)lastUpdate;

+(FZZEvent *)eventWithEID:(NSNumber *)eID;
+(void)setupEventClass;

//-(void)updateEngaged;

+(FZZEvent *)parseJSON:(NSDictionary *)eventJSON;
+(NSArray *)parseEventJSONList:(NSArray *)eventListJSON;

@end

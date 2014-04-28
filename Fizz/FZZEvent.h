//
//  FZZEvent.h
//  Fizz
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "FZZSocketIODelegate.h"

@class FZZUser;
@class FZZMessage;

@interface FZZEvent : NSObject

-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOLeaveEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOInviteWithInviteList:(NSArray *)inviteList
                    InviteContactList:(NSArray *)contactList
                     AndAcknowledge:(SocketIOCallback)function;
-(void)socketIORequestEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOSetSeatCapacityToCapacity:(NSNumber *)capacity
                         WithAcknowledge:(SocketIOCallback)function;
+(void)socketIONewEventWithMessage:(NSString *)message
                        InviteOnly:(BOOL)isInviteOnly
                    AndAcknowledge:(SocketIOCallback)function;

-(NSNumber *)eventID;

-(FZZUser *)creator;
-(NSArray *)messages;

// Guests is a subset of invitees ALWAYS. People who join a non-secret event are "invited"
-(NSArray *)guests;
-(NSArray *)invitees;
// invitees who aren't guests
-(NSArray *)notYetGuests;

//-(NSArray *)engaged;
-(BOOL)isInviteOnly;
-(FZZMessage *)firstMessage;

-(BOOL)isInvited:(FZZUser *)user;
-(BOOL)isGuest:(FZZUser *)user;
-(BOOL)isAtEvent:(FZZUser *)user;

-(BOOL)hasSeats;
-(NSNumber *)pendingNumSeats;
-(NSNumber *)numSeats;
-(NSNumber *)pendingNumEmptySeats;
-(NSNumber *)numEmptySeats;
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

-(void)updateAddAtEvent:(NSArray *)arrivingList;
-(void)updateRemoveAtEvent:(NSArray *)leavingList;

-(BOOL)haveSeatsChangedSinceLastCheck;


// Most recent new thing, used for sorting
-(NSDate *)lastUpdate;

+(FZZEvent *)eventWithEID:(NSNumber *)eID;
+(void)setupEventClass;

//-(void)updateEngaged;

+(FZZEvent *)parseJSON:(NSDictionary *)eventJSON;
+(NSArray *)parseEventJSONList:(NSArray *)eventListJSON;

@end

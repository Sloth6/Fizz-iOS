//
//  FZZEvent.h
//  Fizz
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "FZZSocketIODelegate.h"


/*
 
 FZZEvents work extremely similarly to FZZUsers. Refer to their documentation for more details.
 
 */

@class FZZUser;
@class FZZMessage;

@interface FZZEvent : NSManagedObject

@property (nonatomic, retain) NSNumber *numSeats;
@property (nonatomic, retain) NSNumber *eventID;
@property (nonatomic, retain) FZZUser *creator;
@property (nonatomic, retain) NSArray *messages;
@property (nonatomic, retain) NSArray *inviteesNotGuest;
@property (nonatomic, retain) NSArray *guestsNotPresent;
@property (nonatomic, retain) NSArray *presentAtEvent;

-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOLeaveEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOInviteWithInviteList:(NSArray *)inviteList
                  InviteContactList:(NSArray *)contactList
                     AndAcknowledge:(SocketIOCallback)function;
-(void)socketIOSuggestInviteWithInviteList:(NSArray *)inviteList
                         InviteContactList:(NSArray *)contactList
                            AndAcknowledge:(SocketIOCallback)function;
-(void)socketIORequestEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOSetSeatCapacityToCapacity:(NSNumber *)capacity
                         WithAcknowledge:(SocketIOCallback)function;
+(void)socketIONewEventWithMessage:(NSString *)message
                          AndSeats:(int)numSeats
                    AndAcknowledge:(SocketIOCallback)function;

-(NSNumber *)eventID;

-(FZZUser *)creator;

// Guests is a subset of invitees ALWAYS. People who join a non-secret event are "invited"
//-(NSMutableArray *)guests;
//-(NSMutableArray *)invitees;
// invitees who aren't guests
-(NSArray *)notYetGuests;

//-(NSArray *)engaged;
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

// Updates called from the server updates
-(void)updateAtEvent:(NSArray *)attendees;
-(void)updateGuests:(NSArray *)guests;
-(void)updateAddInvitees:(NSArray *)invitees;

-(void)updateToAttendees:(NSArray *)toAttendees;
-(void)updateToGuests:(NSArray *)toGuests;
-(void)updateToInvitees:(NSArray *)toInvitees;

-(void)updateNumberOfSeats:(NSNumber *)numSeats;
-(void)updateAddMessage:(FZZMessage *)message;

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

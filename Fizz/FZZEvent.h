//
//  FZZEvent.h
//  Fizz
//
//  Created by Andrew Sweet on 5/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SocketIO.h"
#import "FZZCluster.h"

@class FZZMessage, FZZUser;

@interface FZZEvent :  NSObject

@property (nonatomic, strong) NSDate * creationTime;
@property (nonatomic, strong) NSNumber * eventID;
@property (nonatomic, strong) NSArray *clusters;
@property (nonatomic, strong) NSArray *guests;
@property (nonatomic, strong) NSArray *invitees;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) FZZUser *creator;

+(BOOL)saveEventsToFile:(NSString *)eventsURL;
+(void)parseEventsJSONForCache:(NSDictionary *)eventsJSON;
+(NSArray *)getEvents;

-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOLeaveEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOInviteWithInviteList:(NSArray *)inviteList
                  InviteContactList:(NSArray *)contactList
                     AndAcknowledge:(SocketIOCallback)function;
-(void)socketIOLoadMessagesBeforeMID:(NSNumber *)mid
                      AndAcknowledge:(SocketIOCallback)function;
+(void)socketIONewEventWithMessage:(NSString *)message
                    AndAcknowledge:(SocketIOCallback)function;
//+(void)socketIONewEventWithMessage:(NSString *)message
//                          AndSeats:(int)numSeats
//                    AndAcknowledge:(SocketIOCallback)function;

-(NSNumber *)eventID;

-(FZZUser *)creator;

// Guests is a subset of invitees ALWAYS. People who join a non-secret event are "invited"
//-(NSMutableArray *)guests;
//-(NSMutableArray *)invitees;
// invitees who aren't guests

//-(NSArray *)engaged;
-(FZZMessage *)firstMessage;

-(BOOL)isInvited:(FZZUser *)user;
-(BOOL)isGuest:(FZZUser *)user;
-(BOOL)isAtEvent:(FZZUser *)user;

//-(BOOL)hasSeats;
//-(NSNumber *)pendingNumSeats;
//-(NSNumber *)numSeats;
//-(NSNumber *)pendingNumEmptySeats;
//-(NSNumber *)numEmptySeats;
//-(void)addSeat;
//-(BOOL)removeSeat;

//-(BOOL)expressInterest;
-(BOOL)haveExpressedInterest;
-(BOOL)joinEvent;
-(BOOL)leaveEvent;

// Updates called from the server updates
-(void)updateClusters:(NSArray *)clusters;
-(void)updateGuests:(NSArray *)guests;
-(void)updateInvitees:(NSArray *)invitees;

//-(void)updateNumberOfSeats:(NSNumber *)numSeats;
-(void)updateAddMessage:(FZZMessage *)message;

//-(BOOL)haveSeatsChangedSinceLastCheck;


// Most recent new thing, used for sorting
-(NSDate *)lastUpdate;

+(FZZEvent *)eventWithEID:(NSNumber *)eID;
+(void)setupEventClass;

//-(void)updateEngaged;

+(FZZEvent *)parseJSON:(NSDictionary *)eventJSON;
+(NSArray *)parseEventJSONList:(NSArray *)eventListJSON;

+(void)killEvents:(NSArray *)deadEvents;


@end

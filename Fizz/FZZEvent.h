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

@class FZZMessage, FZZUser;

@interface FZZEvent :  NSObject

@property (strong, nonatomic) NSIndexPath *scrollPosition;

@property (nonatomic, strong) NSDate *creationTime;
@property (nonatomic, strong) NSNumber *eventID;
@property (nonatomic, strong) NSArray *guests;
@property (nonatomic, strong) NSArray *invitees;
@property (nonatomic, strong) NSArray *messages;
@property (nonatomic, strong) FZZUser *creator;
@property (nonatomic, strong) NSString *eventDescription;

+(NSArray *)getEventIDs;
+(BOOL)saveEventsToFile:(NSString *)eventsURL;
+(void)parseEventsJSONForCache:(NSDictionary *)eventsJSON;
+(NSArray *)getEvents;

+(NSSet *)confirmEventsAndNumberOfMessages:(NSArray *)eventIDAndMessageNumList;


-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOLeaveEventWithAcknowledge:(SocketIOCallback)function;

// {"pn" : phoneNumber, "name" : name} list
-(void)socketIOInviteWithInviteList:(NSArray *)inviteList
                     AndAcknowledge:(SocketIOCallback)function;
-(void)socketIOLoadMessagesBeforeMID:(NSNumber *)mid
                      AndAcknowledge:(SocketIOCallback)function;
-(void)socketIOUpdateEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIODeleteEventWithAcknowledge:(SocketIOCallback)function;
+(void)socketIONewEventWithMessage:(NSString *)message
                    AndAcknowledge:(SocketIOCallback)function;
+(void)socketIORequestEventsWithIDs:(NSArray *)eventIDs
                     AndAcknowledge:(SocketIOCallback)function;

//+(void)socketIONewEventWithMessage:(NSString *)message
//                          AndSeats:(int)numSeats
//                    AndAcknowledge:(SocketIOCallback)function;

-(NSNumber *)eventID;
-(NSIndexPath *)getEventIndexPath;

-(FZZUser *)creator;
-(NSArray *)inviteesNotGuests;

-(NSArray *)guestsWithoutCreator;
-(NSArray *)inviteesNotGuestsWithoutCreator;

// Guests is a subset of invitees ALWAYS. People who join a non-secret event are "invited"
//-(NSMutableArray *)guests;
//-(NSMutableArray *)invitees;
// invitees who aren't guests

//-(NSArray *)engaged;
-(FZZMessage *)firstMessage;

-(BOOL)isUserInvited:(FZZUser *)user;
-(BOOL)isUserGuest:(FZZUser *)user;

-(BOOL)haveExpressedInterest;
-(BOOL)joinEvent;
-(BOOL)leaveEvent;

// Updates called from the server updates
-(void)updateGuests:(NSArray *)guests;
-(void)updateAddInvitees:(NSArray *)invitees;

//-(void)updateNumberOfSeats:(NSNumber *)numSeats;
-(void)updateAddMessage:(FZZMessage *)message;

-(void)updateEventDescription:(NSString *)eventDescription;

//-(BOOL)haveSeatsChangedSinceLastCheck;


// Most recent new thing, used for sorting
-(NSDate *)lastUpdate;

+(FZZEvent *)eventWithEID:(NSNumber *)eID;
+(void)setupEventClass;

//-(void)updateEngaged;

+(FZZEvent *)parseJSON:(NSDictionary *)eventJSON;
+(NSSet *)parseEventIDList:(NSArray *)eventIDList;

+(void)killEvents:(NSArray *)deadEvents;

+(FZZEvent *)getEventAtIndexPath:(NSIndexPath *)indexPath;

@end

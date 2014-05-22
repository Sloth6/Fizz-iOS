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

@interface FZZEvent : NSManagedObject

@property (nonatomic, retain) NSNumber * eventID;
@property (nonatomic, retain) NSDate * creationTime;

@property (nonatomic, retain) FZZUser *creator;
@property (nonatomic, retain) NSOrderedSet *invitees;
@property (nonatomic, retain) NSOrderedSet *guests;
@property (nonatomic, retain) NSOrderedSet *clusters;
@property (nonatomic, retain) NSOrderedSet *suggestedInvites;

@property (nonatomic, retain) NSOrderedSet *messages;

@end

@interface FZZEvent (CoreDataGeneratedAccessors)

+(NSArray *)getEvents;

- (void)insertObject:(FZZUser *)value inGuestsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromGuestsAtIndex:(NSUInteger)idx;
- (void)insertGuests:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeGuestsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInGuestsAtIndex:(NSUInteger)idx withObject:(FZZUser *)value;
- (void)replaceGuestsAtIndexes:(NSIndexSet *)indexes withGuests:(NSArray *)values;
- (void)addGuestsObject:(FZZUser *)value;
- (void)removeGuestsObject:(FZZUser *)value;
- (void)addGuests:(NSOrderedSet *)values;
- (void)removeGuests:(NSOrderedSet *)values;
- (void)insertObject:(FZZUser *)value inInviteesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromInviteesAtIndex:(NSUInteger)idx;
- (void)insertInvitees:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeInviteesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInInviteesAtIndex:(NSUInteger)idx withObject:(FZZUser *)value;
- (void)replaceInviteesAtIndexes:(NSIndexSet *)indexes withInvitees:(NSArray *)values;
- (void)addInviteesObject:(FZZUser *)value;
- (void)removeInviteesObject:(FZZUser *)value;
- (void)addInvitees:(NSOrderedSet *)values;
- (void)removeInvitees:(NSOrderedSet *)values;
- (void)insertObject:(FZZMessage *)value inMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx;
- (void)insertMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(FZZMessage *)value;
- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray *)values;
- (void)addMessagesObject:(FZZMessage *)value;
- (void)removeMessagesObject:(FZZMessage *)value;
- (void)addMessages:(NSOrderedSet *)values;
- (void)removeMessages:(NSOrderedSet *)values;
- (void)insertObject:(FZZCluster *)value inClustersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromClustersAtIndex:(NSUInteger)idx;
- (void)insertClusters:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeClustersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInClustersAtIndex:(NSUInteger)idx withObject:(FZZCluster *)value;
- (void)replaceClustersAtIndexes:(NSIndexSet *)indexes withClusters:(NSArray *)values;
- (void)addClustersObject:(FZZCluster *)value;
- (void)removeClustersObject:(FZZCluster *)value;
- (void)addClusters:(NSOrderedSet *)values;
- (void)removeClusters:(NSOrderedSet *)values;

- (void)insertObject:(FZZUser *)value inSuggestedInvitesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromSuggestedInvitesAtIndex:(NSUInteger)idx;
- (void)insertSuggestedInvites:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeSuggestedInvitesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInSuggestedInvitesAtIndex:(NSUInteger)idx withObject:(FZZUser *)value;
- (void)replaceSuggestedInvitesAtIndexes:(NSIndexSet *)indexes withSuggestedInvites:(NSArray *)values;
- (void)addSuggestedInvitesObject:(FZZUser *)value;
- (void)removeSuggestedInvitesObject:(FZZUser *)value;
- (void)addSuggestedInvites:(NSOrderedSet *)values;
- (void)removeSuggestedInvites:(NSOrderedSet *)values;

-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOLeaveEventWithAcknowledge:(SocketIOCallback)function;
-(void)socketIOHostInviteWithInviteList:(NSArray *)inviteList
                      InviteContactList:(NSArray *)contactList
                         AndAcknowledge:(SocketIOCallback)function;
-(void)socketIOSuggestInviteWithInviteList:(NSArray *)inviteList
                         InviteContactList:(NSArray *)contactList
                            AndAcknowledge:(SocketIOCallback)function;
-(void)socketIOLoadMessagesBeforeMID:(NSNumber *)mid
                      AndAcknowledge:(SocketIOCallback)function;
//-(void)socketIOSetSeatCapacityToCapacity:(NSNumber *)capacity
//                         WithAcknowledge:(SocketIOCallback)function;
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
-(NSArray *)notYetGuests;

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

//
//  FZZEvent.m
//  Fizz
//
//  Created by Andrew Sweet on 5/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZEvent.h"
#import "FZZMessage.h"
#import "FZZUser.h"
#import "SocketIO.h"
#import "FZZSocketIODelegate.h"
#import "FZZAppDelegate.h"
#import "FZZCluster.h"

static NSMutableDictionary *events;

static NSString *FZZ_NEW_EVENT   = @"newEvent";
static NSString *FZZ_JOIN_EVENT  = @"joinEvent";
static NSString *FZZ_LEAVE_EVENT = @"leaveEvent";
//static NSString *FZZ_SET_SEAT_CAPACITY = @"setSeatCapacity";
static NSString *FZZ_NEW_INVITES = @"newInvites";
static NSString *FZZ_SUGGEST_INVITED_LIST = @"suggestInvitedList";
static NSString *FZZ_GET_MORE_MESSAGES = @"getMoreMessages";


@interface FZZEvent ()

//@property NSTimer *seatTimer;

//@property (strong, nonatomic) NSMutableArray *presentAtEvent;
//@property (strong, nonatomic) NSMutableArray *guests;
//@property (strong, nonatomic) NSMutableArray *invitees;

@property (nonatomic) BOOL haveExpressedInterest;
//@property BOOL haveSeatsChanged;

//@property (strong, nonatomic) NSNumber *numSeats;
//@property (strong, nonatomic) NSNumber *pendingNumSeats;

@property (strong, nonatomic) NSDate *lastUpdate;

@end

@implementation FZZEvent

@dynamic creationTime;
@dynamic eventID;
@dynamic clusters;
@dynamic creator;
@dynamic guests;
@dynamic invitees;
@dynamic messages;
@dynamic suggestedInvites;

//@synthesize haveSeatsChanged = _haveSeatsChanged;
@synthesize haveExpressedInterest = _haveExpressedInterest;

+(void)setupEventClass{
    if (!events){
        events = [[NSMutableDictionary alloc] init];
    }
}

-(NSEntityDescription *)getEntityDescription{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    return [NSEntityDescription entityForName:@"FZZEvent" inManagedObjectContext:moc];
}

-(id)init{
//    self = [super init];
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    self = [NSEntityDescription insertNewObjectForEntityForName:@"FZZEvent" inManagedObjectContext:moc];
    
//    NSEntityDescription *entityDescription = [self getEntityDescription];
//    self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
    
    //    self = (FZZEvent *)[FZZDataStore insertNewObjectForEntityForName:@"FZZEvent"];
    
    if (self){
//        _haveSeatsChanged = YES;
        _haveExpressedInterest = NO;
    }
    
    return self;
}

-(void)dealloc {
    [events removeObjectForKey:self.eventID];
}


-(id)initWithEID:(NSNumber *)eID{
    if (!eID){
        return NULL;
    }
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
//    NSEntityDescription *entityDescription = [self getEntityDescription];
//    self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:moc];

    self = [NSEntityDescription insertNewObjectForEntityForName:@"FZZEvent" inManagedObjectContext:moc];
    
//    self = [super init];
    //    self = (FZZEvent *)[FZZDataStore insertNewObjectForEntityForName:@"FZZEvent"];
    
    if (self){
//        _haveSeatsChanged = YES;
        self.eventID = eID;
        [events setObject:self forKey:eID];
    }
    
    return self;
}

+(NSArray *)getEvents{
    NSArray *allEvents = [events allValues];
    return [allEvents sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        FZZEvent *e1 = obj1;
        FZZEvent *e2 = obj2;
        
        return [[e1 creationTime] compare:[e2 creationTime]];
    }];
}

#pragma mark Accessors

//-(NSArray *)engaged{
//    return [self.engaged copy];
//}

//-(BOOL)hasSeats{
//    return (self.numSeats != nil);
//}
//
//-(NSNumber *)pendingNumSeats{
//    return self.pendingNumSeats;
//}
//
//-(NSNumber *)numSeats{
//    return self.numSeats;
//}
//
//-(NSNumber *)pendingNumEmptySeats{
//    if (!self.numSeats){
//        return NULL;
//    
//    int result = MAX([self.pendingNumSeats integerValue] - [self.guests count], 0);
//    
//    
//    return [NSNumber numberWithInt:result];
//}
//
//-(NSNumber *)numEmptySeats{
//    if (!self.numSeats){
//        return NULL;
//    }
//    
//    int result = MAX([self.numSeats integerValue] - [self.guests count], 0);
//    
//    return [NSNumber numberWithInt:result];
//}

+(FZZEvent *)eventWithEID:(NSNumber *)eID{
    if (!eID) return NULL;
    
    FZZEvent *event = [events objectForKey:eID];
    
    if (event == NULL){
        
        // Attempt to load from cache
        
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
        NSManagedObjectContext *moc = [appDelegate managedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"FZZEvent" inManagedObjectContext:moc];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID = %@", eID];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        
        NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
        
        if ([results count] > 0){
            
            NSLog(@"GOOD NEWS EVERYONE\n------------\n%@\n\n", results);
            
            event = [results objectAtIndex:0];
        } else {
            event = [[FZZEvent alloc] initWithEID:eID];
        }
    }
    
    return event;
}

-(BOOL)isInvited:(FZZUser *)user{
    return [self.invitees containsObject:user];
}

-(BOOL)isGuest:(FZZUser *)user{
    return [self.guests containsObject:user];
}

-(BOOL)isAtEvent:(FZZUser *)user{
    for (int i = 0; i < [self.clusters count]; ++i){
        NSOrderedSet *cluster = [self.clusters objectAtIndex:i];
        if ([cluster containsObject:user]){
            return YES;
        }
    }
    
    return NO;
}

-(FZZMessage *)firstMessage{
    if ([self.messages count] > 0){
        return [self.messages objectAtIndex:0];
    }
    
    return NULL;
}

// You can always add a seat
//- (void)addSeat{
//    @synchronized(self){
//        if (self.pendingNumSeats){
//            [self restartTimer];
//            
//            self.haveSeatsChanged = YES;
//            
//            self.pendingNumSeats = [NSNumber numberWithInt:[self.pendingNumSeats integerValue] + 1];
//        }
//    }
//}

//-(void)updateNumberOfSeats:(NSNumber *)numSeats{
//    @synchronized(self){
//        _haveSeatsChanged = YES;
//        self.numSeats = [numSeats copy];
//        _pendingNumSeats = self.numSeats;
//    }
//}

-(void)updateClusters:(NSArray *)clusters{
    @synchronized(self){
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:clusters];
        
        [self setClusters:orderedSet];
    }
}

-(void)updateGuests:(NSArray *)guests{
    @synchronized(self){
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:guests];
        
        [self setGuests:orderedSet];
    }
}

-(void)updateInvitees:(NSArray *)invitees{
    @synchronized(self){
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:invitees];
        
        [self setInvitees:orderedSet];
    }
}


//-(void)updateRemoveGuest:(FZZUser *)guest{
//    @synchronized(self){
//        [self removePresentAtEvent:[NSOrderedSet orderedSetWithObject:guest]];
////        [self.guestsNotPresent removeObject:guest];
//    }
//}
//
//-(void)updateAtEvent:(NSArray *)attendees{
//    @synchronized(self){
//        NSOrderedSet *attendeesOrderedSet = [NSOrderedSet orderedSetWithArray:attendees];
//        
//        self.presentAtEvent = attendeesOrderedSet;
//        
//        [self removeGuestsNotPresent:attendeesOrderedSet];
//        [self removeInviteesNotGuest:attendeesOrderedSet];
//    }
//}
//
//-(void)updateGuests:(NSArray *)guests{
//    @synchronized(self){
//        NSMutableArray *presentAtEvent = [self.presentAtEvent mutableCopy];
//        
//        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:guests];
//        
//        self.guestsNotPresent = orderedSet;
//        [self removePresentAtEvent:orderedSet];
//        [self removeInviteesNotGuest:orderedSet];
//    }
//}
//
//-(void)updateAddInvitees:(NSArray *)invitees{
//    @synchronized(self){
//        // Ensure no duplicates
//        
//        
//        [self.invitees removeObjectsInArray:invitees];
//        [self.invitees addObjectsFromArray:invitees];
//        
//        [self.inviteesSet addObjectsFromArray:invitees];
//    }
//}
//
//-(void)updateToAttendees:(NSArray *)toAttendees{
//    @synchronized(self){
//        NSMutableArray *presentAtEvent = [self.presentAtEvent mutableCopy];
//        
//        [presentAtEvent removeObjectsInArray:toAttendees];
//        [presentAtEvent addObjectsFromArray:toAttendees];
//        self.presentAtEvent = presentAtEvent;
//        
//        [self.guests removeObjectsInArray:toAttendees];
//        [self.invitees removeObjectsInArray:toAttendees];
//    }
//}
//
//-(void)updateToGuests:(NSArray *)toGuests{
//    @synchronized(self){
//        NSMutableArray *presentAtEvent = [self.presentAtEvent mutableCopy];
//        
//        [presentAtEvent removeObjectsInArray:toGuests];
//        self.presentAtEvent = presentAtEvent;
//        
//        [self.guests removeObjectsInArray:toGuests];
//        [self.invitees removeObjectsInArray:toGuests];
//        
//        [self.guests addObjectsFromArray:toGuests];
//    }
//}
//
//-(void)updateToInvitees:(NSArray *)toInvitees{
//    @synchronized(self){
//        NSMutableArray *presentAtEvent = [self.presentAtEvent mutableCopy];
//        
//        [presentAtEvent removeObjectsInArray:toInvitees];
//        self.presentAtEvent = presentAtEvent;
//        
//        [self.guests removeObjectsInArray:toInvitees];
//        [self.invitees removeObjectsInArray:toInvitees];
//        
//        [self.invitees addObjectsFromArray:toInvitees];
//    }
//}

-(void)updateAddMessage:(FZZMessage *)message{
    @synchronized(self){
        
        [self addMessages:[[NSOrderedSet alloc] initWithObject:message]];
        
        NSArray *items = [self.messages sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
            FZZMessage *m1 = obj1;
            FZZMessage *m2 = obj2;
            
            return [[m1 messageID] compare:[m2 messageID]];
        }];
        
        self.messages = [[NSOrderedSet alloc] initWithArray:items];
    }
}

// Attempt to subtract an empty seat. If no empty seats, no subtraction
//- (BOOL)removeSeat{
//    @synchronized(self){
//        [self restartTimer];
//        
//        int pendingNumSeats = [self.pendingNumSeats integerValue];
//        int numOccupiedSeats = [self.guests count];
//        
//        if (pendingNumSeats > numOccupiedSeats){
//            self.haveSeatsChanged = YES;
//            self.pendingNumSeats = [NSNumber numberWithInt:pendingNumSeats - 1];
//            
//            return YES;
//        } else {
//            return NO;
//        }
//    }
//}

//-(BOOL)expressInterest{
//    FZZUser *me = [FZZUser me];
//    
//    if ([self isInvited:me]){
//        return NO;
//    }
//    
//    if (self.haveExpressedInterest){
//        return NO;
//    }
//    
//    self.haveExpressedInterest = YES;
//    
//    [self socketIORequestEventWithAcknowledge:NULL];
//    
//    return YES;
//}

-(BOOL)haveExpressedInterest{
    return self.haveExpressedInterest;
}

-(BOOL)joinEvent{
    FZZUser *me = [FZZUser me];
    
    if ([self isGuest:me] || ![self isInvited:me]){
        return NO;
    }
    
    [self socketIOJoinEventWithAcknowledge:NULL];
    
    // TODOAndrew Visually join the event temporarily, waiting for server confirmation
    
    return YES;
}

-(BOOL)leaveEvent{
    FZZUser *me = [FZZUser me];
    
    @synchronized(self){
        if (![self isGuest:me]){
            return NO;
        }
    
        // Attempt to remove from cluster
    
        for (int i = 0; i < [self.clusters count]; ++i){
            FZZCluster *cluster = [self.clusters objectAtIndex:i];
            
            if ([cluster.users containsObject:me]){
                
                [cluster removeUsersObject:me];
                break;
            }
        }
        
        [self removeGuestsObject:me];
        [self removeInviteesObject:me];
    }
    
    [self socketIOLeaveEventWithAcknowledge:NULL];
    
    return YES;
}

//-(BOOL)haveSeatsChangedSinceLastCheck{
//    BOOL result = self.haveSeatsChanged;
//    
//    self.haveSeatsChanged = NO;
//    
//    return result;
//}
//
//- (void)pushSeatsToServer{
//    self.seatTimer = NULL;
//    
//    // Don't send anything if nothing has changed
//    if ([self.numSeats isEqualToNumber:self.pendingNumSeats]){
//        return;
//    }
//    
//    self.numSeats = self.pendingNumSeats;
//    
//    // Perform the push to the server
//    [self socketIOSetSeatCapacityToCapacity:self.numSeats
//                            WithAcknowledge:nil];
//}
//
//// Call this every time the seats change, it ensures 1.6 second after the last seat change
//// The data will be pushed to the server if need be
//// Avoids spamming the server
//- (void)restartTimer{
//    [self.seatTimer invalidate];
//    
//    self.seatTimer = [NSTimer scheduledTimerWithTimeInterval:1.6
//                                                      target:self
//                                                    selector:@selector(pushSeatsToServer)
//                                                    userInfo:nil
//                                                     repeats:NO];
//}


-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_JOIN_EVENT withData:json andAcknowledge:function];
}

-(void)socketIOLoadMessagesBeforeMID:(NSNumber *)mid
                      AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* eid : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    /* mid : int */
    [json setObject:mid forKey:@"oldestMid"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_GET_MORE_MESSAGES withData:json andAcknowledge:function];
}

/*-(void)socketIODeleteEventWithAcknowledge:(SocketIOCallback)function{
 NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
 
 // id : int
 [json setObject:eventID forKey:@"id"];
 
 FZZ_IOSocketDelegate *socketIODelegate = [FZZObject getIOSocketDelegate];
 
 [[socketIODelegate socketIO] sendEvent:FZZ_DELETE_EVENT withData:json andAcknowledge:function];
 }*/

-(void)socketIOLeaveEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_LEAVE_EVENT withData:json andAcknowledge:function];
}

-(void)socketIOHostInviteWithInviteList:(NSArray *)inviteList
                      InviteContactList:(NSArray *)contactList
                         AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* eid : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    /* inviteList : user array */
    NSArray *userArray = [FZZUser usersToJSONUsers:inviteList];
    [json setObject:userArray forKey:@"inviteList"];
    
    /* invitePnList : {name : string, pn :string} array */
    // Any user without a UID, send their name and phone number
    [json setObject:contactList forKey:@"invitePnList"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_INVITES withData:json andAcknowledge:function];
}

-(void)socketIOSuggestInviteWithInviteList:(NSArray *)inviteList
                         InviteContactList:(NSArray *)contactList
                            AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* eid : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    /* inviteList : user array */
    NSArray *userArray = [FZZUser usersToJSONUsers:inviteList];
    [json setObject:userArray forKey:@"uidList"];
    
    /* invitePnList : {name : string, pn :string} array */
    // Any user without a UID, send their name and phone number
    [json setObject:contactList forKey:@"pnList"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_SUGGEST_INVITED_LIST withData:json andAcknowledge:function];
}

//-(void)socketIOSetSeatCapacityToCapacity:(NSNumber *)capacity
//                         WithAcknowledge:(SocketIOCallback)function{
//    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
//    
//    /* id : int */
//    [json setObject:self.eventID forKey:@"eid"];
//    
//    /* seats : int */
//    [json setObject:capacity forKey:@"seats"];
//    
//    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_SET_SEAT_CAPACITY withData:json andAcknowledge:function];
//}

+(void)socketIONewEventWithMessage:(NSString *)message
                    AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* text : string */
    [json setObject:message forKey:@"text"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_EVENT withData:json andAcknowledge:function];
}

//+(void)socketIONewEventWithMessage:(NSString *)message
//                          AndSeats:(int)numSeats
//                    AndAcknowledge:(SocketIOCallback)function{
//    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
//    
//    /* seats : int */
//    [json setObject:[NSNumber numberWithInt:numSeats] forKey:@"seats"];
//    
//    /* text : string */
//    [json setObject:message forKey:@"text"];
//    
//    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_EVENT withData:json andAcknowledge:function];
//}

/*-(NSArray *)getJsonComments{
 NSMutableArray *json = [[NSMutableArray alloc] init];
 
 for (int i = 0; i < [comments count]; i++){
 NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
 FZZComment *comment = [comments objectAtIndex:i];
 
 NSString *nameOfUser = [[comment user] name];
 NSString *text = [comment text];
 
 [dict setObject:text forKey:@"comment"];
 [dict setObject:nameOfUser forKey:@"user"];
 
 [json addObject:dict];
 }
 
 return json;
 }*/

-(NSMutableArray *)getArrayOfUniqueCommenters{
    // Get all unique commenters
    NSMutableSet   *seenUsers   = [[NSMutableSet   alloc] init];
    NSMutableArray *uniqueUsers = [[NSMutableArray alloc] init];
    
    int numUniqueUsers = [uniqueUsers count];
    int numComments    = [self.messages count];
    
    for (int j = 0; j < numComments; j++){
        FZZMessage *message = [self.messages objectAtIndex:j];
        FZZUser    *user    = [message user];
        
        if (![seenUsers containsObject:user]){
            [seenUsers addObject:user];
            [uniqueUsers addObject:user];
            numUniqueUsers++;
        }
    }
    
    return uniqueUsers;
}

-(NSMutableArray *)takeCommentingGuestsFromCommenters:(NSMutableArray *)uCommenters
                                            andGuests:(NSMutableArray *)uGuests{
    NSSet *guestsSet = [NSSet setWithArray:uGuests];
    int numCommenters = [uCommenters count];
    int count = 0;
    
    NSMutableArray *commentingGuests = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numCommenters; ++i){
        FZZUser *user = [uCommenters objectAtIndex:i];
        if ([guestsSet containsObject:user]){
            [commentingGuests addObject:user];
            [uCommenters removeObject:user];
            [uGuests removeObject:user];
            ++count;
        }
    }
    
    return commentingGuests;
}

//-(void)updateEngaged{
//    NSMutableArray *uniqueCommenters = [self getArrayOfUniqueCommenters];
//
//    NSMutableArray *uniqueAttendees = [attendees copy];
//
//    // Removes commentingAttendees from uniqueCommenters and attendees
//    NSMutableArray *commentingAttendees = [self takeCommentingAttendeesFromCommenters:uniqueCommenters
//                                                                         andAttendees:uniqueAttendees];
//
//    NSMutableArray *engagedTemp = commentingAttendees;
//
//    [engagedTemp addObjectsFromArray:uniqueCommenters];
//    [engagedTemp addObjectsFromArray:uniqueAttendees];
//
//    self.engaged = engagedTemp;
//}

+(FZZEvent *)parseJSON:(NSDictionary *)eventJSON{
    if (eventJSON == NULL){
        return NULL;
    }
    
    /* Event ID */
    NSNumber *eid = [eventJSON objectForKey:@"eid"];
    
    
    /* Creator uID */
    FZZUser *creator;
    
    NSNumber *creatorUID = [eventJSON objectForKey:@"creator"];
    creator = [FZZUser userWithUID:creatorUID];
    
    creatorUID = nil;
    
    /* Creation Time */
    NSDate *creationTime = [eventJSON objectForKey:@"creationTime"];
    
    NSArray *messages = [eventJSON objectForKey:@"messages"];
    
    /* Allocate Memory and Assign Values */
    FZZEvent *event = [FZZEvent eventWithEID:eid];
    
    event.creator = creator;
    [creator addCreatorOfObject:event];
    
    event.creationTime = creationTime;
    
    // load messages if they are contained in the event object
    if (messages != Nil){
        NSMutableArray *mutMessages = [messages mutableCopy];
        
        [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FZZMessage *message = [FZZMessage parseJSON:obj];
            
            [message setEvent:event];
            [mutMessages setObject:message atIndexedSubscript:idx];
        }];
        
        [event setMessages:[NSOrderedSet orderedSetWithArray:mutMessages]];
    }
    
    return event;
}

+(NSArray *)parseEventJSONList:(NSArray *)eventListJSON{
    if (eventListJSON == NULL){
        return NULL;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:eventListJSON];
    
    [eventListJSON enumerateObjectsUsingBlock:^(id eventJSON, NSUInteger index, BOOL *stop) {
        FZZEvent *event = [FZZEvent parseJSON:eventJSON];
        [result setObject:event atIndexedSubscript:index];
    }];
    
    return result;
}

+(void)saveObjects{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

+(void)killEvents:(NSArray *)deadEvents{
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *moc = [appDelegate managedObjectContext];
    
    [deadEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *eID = obj;
        
        FZZEvent *event = [events objectForKey:eID];
        
        [moc deleteObject:event];
        [events removeObjectForKey:eID];
    }];
    
    [self saveObjects];
}

-(NSDate *)lastUpdate{
    int count = [self.messages count];
    
    if (count != 0){ // Should always be > 0
        FZZMessage *message = [self.messages objectAtIndex:count - 1];
        
        return [message creationTime];
    }
    
    // Never updated
    return [NSDate distantPast];
}


#pragma mark - Getters and Setters
/*
 
 Apple's auto-generated getters and setters for NSManagedObject's NSOrderedSets are broken.
 
 */

//- (void)insertObject:(FZZCluster *)value inClustersAtIndex:(NSUInteger)idx;
static NSString *const kClustersKey = @"clusters";

- (void)insertObject:(FZZCluster *)value inClustersAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kClustersKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kClustersKey]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kClustersKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kClustersKey];
}

- (void)removeObjectFromClustersAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kClustersKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kClustersKey]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kClustersKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kClustersKey];
}

- (void)insertClusters:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kClustersKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kClustersKey]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kClustersKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kClustersKey];
}

- (void)removeClustersAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kClustersKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kClustersKey]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kClustersKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kClustersKey];
}

- (void)replaceObjectInClustersAtIndex:(NSUInteger)idx withObject:(FZZCluster *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kClustersKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kClustersKey]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kClustersKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kClustersKey];
}

- (void)replaceClustersAtIndexes:(NSIndexSet *)indexes withClusters:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kClustersKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kClustersKey]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:kClustersKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kClustersKey];
}

- (void)addClustersObject:(FZZCluster *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kClustersKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kClustersKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kClustersKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kClustersKey];
}

- (void)removeClustersObject:(FZZCluster *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kClustersKey]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kClustersKey];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:kClustersKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kClustersKey];
    }
}

- (void)addClusters:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kClustersKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kClustersKey];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:kClustersKey];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kClustersKey];
    }
}

- (void)removeClusters:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kClustersKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kClustersKey];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:kClustersKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kClustersKey];
    }
}

//- (void)insertObject:(FZZUser *)value inGuestsAtIndex:(NSUInteger)idx;
static NSString *const kGuestsKey = @"guests";

- (void)insertObject:(FZZUser *)value inGuestsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kGuestsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kGuestsKey]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kGuestsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kGuestsKey];
}

- (void)removeObjectFromGuestsAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kGuestsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kGuestsKey]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kGuestsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kGuestsKey];
}

- (void)insertGuests:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kGuestsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kGuestsKey]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kGuestsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kGuestsKey];
}

- (void)removeGuestsAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kGuestsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kGuestsKey]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kGuestsKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kGuestsKey];
}

- (void)replaceObjectInGuestsAtIndex:(NSUInteger)idx withObject:(FZZUser *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kGuestsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kGuestsKey]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kGuestsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kGuestsKey];
}

- (void)replaceGuestsAtIndexes:(NSIndexSet *)indexes withGuests:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kGuestsKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kGuestsKey]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:kGuestsKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kGuestsKey];
}

- (void)addGuestsObject:(FZZUser *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kGuestsKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kGuestsKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kGuestsKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kGuestsKey];
}

- (void)removeGuestsObject:(FZZUser *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kGuestsKey]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kGuestsKey];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:kGuestsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kGuestsKey];
    }
}

- (void)addGuests:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kGuestsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kGuestsKey];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:kGuestsKey];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kGuestsKey];
    }
}

- (void)removeGuests:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kGuestsKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kGuestsKey];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:kGuestsKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kGuestsKey];
    }
}

//- (void)insertObject:(FZZUser *)value inInviteesAtIndex:(NSUInteger)idx;
static NSString *const kInviteesKey = @"invitees";

- (void)insertObject:(FZZUser *)value inInviteesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kInviteesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kInviteesKey]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kInviteesKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kInviteesKey];
}

- (void)removeObjectFromInviteesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kInviteesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kInviteesKey]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kInviteesKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kInviteesKey];
}

- (void)insertInvitees:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kInviteesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kInviteesKey]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kInviteesKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kInviteesKey];
}

- (void)removeInviteesAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kInviteesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kInviteesKey]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kInviteesKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kInviteesKey];
}

- (void)replaceObjectInInviteesAtIndex:(NSUInteger)idx withObject:(FZZUser *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kInviteesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kInviteesKey]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kInviteesKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kInviteesKey];
}

- (void)replaceInviteesAtIndexes:(NSIndexSet *)indexes withInvitees:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kInviteesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kInviteesKey]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:kInviteesKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kInviteesKey];
}

- (void)addInviteesObject:(FZZUser *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kInviteesKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kInviteesKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kInviteesKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kInviteesKey];
}

- (void)removeInviteesObject:(FZZUser *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kInviteesKey]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kInviteesKey];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:kInviteesKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kInviteesKey];
    }
}

- (void)addInvitees:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kInviteesKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kInviteesKey];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:kInviteesKey];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kInviteesKey];
    }
}

- (void)removeInvitees:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kInviteesKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kInviteesKey];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:kInviteesKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kInviteesKey];
    }
}

//- (void)insertObject:(FZZMessage *)value inMessagesAtIndex:(NSUInteger)idx;
static NSString *const kMessagesKey = @"messages";

- (void)insertObject:(FZZMessage *)value inMessagesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kMessagesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kMessagesKey]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kMessagesKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kMessagesKey];
}

- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kMessagesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kMessagesKey]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kMessagesKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kMessagesKey];
}

- (void)insertMessages:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kMessagesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kMessagesKey]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kMessagesKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kMessagesKey];
}

- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kMessagesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kMessagesKey]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kMessagesKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kMessagesKey];
}

- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(FZZMessage *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kMessagesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kMessagesKey]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kMessagesKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kMessagesKey];
}

- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kMessagesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kMessagesKey]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:kMessagesKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kMessagesKey];
}

- (void)addMessagesObject:(FZZMessage *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kMessagesKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kMessagesKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kMessagesKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kMessagesKey];
}

- (void)removeMessagesObject:(FZZMessage *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kMessagesKey]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kMessagesKey];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:kMessagesKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kMessagesKey];
    }
}

- (void)addMessages:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kMessagesKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kMessagesKey];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:kMessagesKey];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kMessagesKey];
    }
}

- (void)removeMessages:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kMessagesKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kMessagesKey];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:kMessagesKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kMessagesKey];
    }
}

//- (void)insertObject:(FZZUser *)value inSuggestedInvitesAtIndex:(NSUInteger)idx;
static NSString *const kSuggestedInvitesKey = @"suggestedInvites";

- (void)insertObject:(FZZUser *)value inSuggestedInvitesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSuggestedInvitesKey]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSuggestedInvitesKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
}

- (void)removeObjectFromSuggestedInvitesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSuggestedInvitesKey]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSuggestedInvitesKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
}

- (void)insertSuggestedInvites:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSuggestedInvitesKey]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSuggestedInvitesKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
}

- (void)removeSuggestedInvitesAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSuggestedInvitesKey]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSuggestedInvitesKey];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
}

- (void)replaceObjectInSuggestedInvitesAtIndex:(NSUInteger)idx withObject:(FZZUser *)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSuggestedInvitesKey]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSuggestedInvitesKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
}

- (void)replaceSuggestedInvitesAtIndexes:(NSIndexSet *)indexes withSuggestedInvites:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSuggestedInvitesKey]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSuggestedInvitesKey];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
}

- (void)addSuggestedInvitesObject:(FZZUser *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSuggestedInvitesKey]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:kSuggestedInvitesKey];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
}

- (void)removeSuggestedInvitesObject:(FZZUser *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSuggestedInvitesKey]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:kSuggestedInvitesKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
    }
}

- (void)addSuggestedInvites:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSuggestedInvitesKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:kSuggestedInvitesKey];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
    }
}

- (void)removeSuggestedInvites:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:kSuggestedInvitesKey]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:kSuggestedInvitesKey];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:kSuggestedInvitesKey];
    }
}

@end

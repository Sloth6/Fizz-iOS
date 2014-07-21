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

#import "FZZCoreDataStore.h"

static NSMutableDictionary *events;

static NSString *FZZ_NEW_EVENT    = @"newEvent";
static NSString *FZZ_DELETE_EVENT = @"deleteEvent";
static NSString *FZZ_JOIN_EVENT   = @"joinEvent";
static NSString *FZZ_LEAVE_EVENT  = @"leaveEvent";
//static NSString *FZZ_SET_SEAT_CAPACITY = @"setSeatCapacity";
static NSString *FZZ_NEW_INVITES  = @"newInvites";
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

@synthesize haveExpressedInterest = _haveExpressedInterest;

+(void)fetchAll{
    [FZZEvent fetchAllEvents];
//    [FZZEvent performSelectorOnMainThread:@selector(fetchAllEvents)
//                               withObject:nil waitUntilDone:YES];
}

+(void)fetchAllEvents{
    NSManagedObjectContext *moc = [FZZCoreDataStore getAppropriateManagedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSArray *fetchedObjects;
    
    [request setEntity:[NSEntityDescription entityForName:@"FZZEvent" inManagedObjectContext:moc]];
    
    [request setPropertiesToFetch:[NSArray arrayWithObjects:@"creationTime", @"eventID", @"location", @"time", @"creator", nil]];
        
    //    [request setResultType:NSDictionaryResultType];
    
    @synchronized(moc){
        fetchedObjects = [moc executeFetchRequest:request error:nil];
    }
        
    for (NSManagedObject *info in fetchedObjects) {
        NSNumber *eID = [info valueForKey:@"eventID"];
        
        if (![events objectForKey:eID]){
            [events setObject:info forKey:eID];
        }
    }
}

+ (instancetype)createManagedObject
{
    NSLog(@"Created FZZEvent");
    
    NSManagedObjectContext *context = [FZZCoreDataStore getAppropriateManagedObjectContext];
    
    FZZEvent *result;
    
    @synchronized(context){
        result = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
        
        [context save:nil];
    }
    
    return result;
}

+(void)setupEventClass{
    if (!events){
        events = [[NSMutableDictionary alloc] init];
    }
}

-(void)dealloc {
    [events removeObjectForKey:self.eventID];
}


-(id)initWithEID:(NSNumber *)eID{
    if (!eID){
        return NULL;
    }

    self = [FZZEvent createManagedObject];
    
    if (self){
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
    
    __block FZZEvent *event = [events objectForKey:eID];
    
    if (event == NULL){

        event = [[FZZEvent alloc] initWithEID:eID];
        
//        // Attempt to load from cache
//        
//        [[FZZCoreDataStore getAppropriateManagedObjectContext] performBlockAndWait:^{
//            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FZZEvent"];
//            
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID = %@", eID];
//            
//            [fetchRequest setPredicate:predicate];
//            
////            [fetchRequest setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"clusters", @"creator", "@guests", @"invitees", @"messages", @"suggestedInvites", nil]];
//            
//            NSManagedObjectContext *moc = [FZZCoreDataStore privateQueueContext];
//            NSArray *results;
//            
//            @synchronized([moc persistentStoreCoordinator]) {
//                results = [moc executeFetchRequest:fetchRequest
//                                             error:nil];
//            }
//            
//            if ([results count] > 0){
//                
//                NSLog(@"GOOD NEWS EVERYONE\n------------\n%@\n\n", results);
//                
//                event = [results objectAtIndex:0];
//            } else {
//                
//            }
//        }];
        
        
//        IAThreadSafeContext *moc = [appDelegate managedObjectContext];
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription
//                                       entityForName:@"FZZEvent" inManagedObjectContext:moc];
//        [fetchRequest setEntity:entity];
//        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eventID = %@", eID];
//        
//        [fetchRequest setPredicate:predicate];
//        
//        NSArray *results;
//        NSError *error = nil;
//        results = [moc executeFetchRequest:fetchRequest error:&error];
        
        
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

-(void)socketIOInviteWithInviteList:(NSArray *)inviteList
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

/*
 
 TODOAndrew Delete event from cache as well on delete
 
 */
-(void)socketIODeleteEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* eid : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_DELETE_EVENT withData:json andAcknowledge:function];
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
    NSLog(@"event before: %@", eventJSON);
    
    if (eventJSON == NULL){
        return NULL;
    }
    
    NSLog(@">>A>>");
    
    /* Event ID */
    NSNumber *eid = [eventJSON objectForKey:@"eid"];
    
    NSLog(@">>A1>>");
    
    /* Creator uID */
    FZZUser *creator;
    
    NSLog(@">>A2>>");
    
    NSNumber *creatorUID = [eventJSON objectForKey:@"creator"]; NSLog(@">>A3>>");
    creator = [FZZUser userWithUID:creatorUID];
    
    NSLog(@">>B>>");
    
    creatorUID = nil;
    
    /* Creation Time */
    NSNumber *creationTimeInterval = [eventJSON objectForKey:@"creationTime"];
    
    NSDate *creationTime = [NSDate dateWithTimeIntervalSince1970:[creationTimeInterval longValue]];
    
    NSArray *messages = [eventJSON objectForKey:@"messages"];
    
    NSLog(@">>C>>");
    
    /* Allocate Memory and Assign Values */
    FZZEvent *event = [FZZEvent eventWithEID:eid];
    
    NSLog(@"event: %@", event);
    
    /* Location */
    NSString *location = [eventJSON objectForKey:@"location"];
    
    NSLog(@">>D>>");
    
    if ((NSObject *)location != [NSNull null]){
        event.location = location;
    }
    
    /* Event Time */
    NSObject *eventTimeInterval = [eventJSON objectForKey:@"time"];
    
    NSLog(@">>E>>");
    
    if (eventTimeInterval != [NSNull null]){
        
        NSLog(@"test1");
        NSNumber *interval = (NSNumber *)eventTimeInterval;
        
        NSLog(@"test0");
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:[interval longValue]];
        
        NSLog(@"test-1");
        event.time = time;
    }
    
    NSLog(@"test2");
    
    event.creator = creator;
    
    
    NSLog(@"test3");
    
//    NSSet *eventsCreated = [creator creatorOf];
//    
//    NSMutableSet *mutEventsCreated = [eventsCreated mutableCopy];
//    [mutEventsCreated addObject:event];
    
//    [creator setCreatorOf:mutEventsCreated];
    
    [creator addCreatorOfObject:event];
    
    NSLog(@"test4");
    
    event.creationTime = creationTime;
    
    NSLog(@">>F>>");
    
    // load messages if they are contained in the event object
    if ((NSObject *)messages != [NSNull null]){
        NSMutableArray *mutMessages = [messages mutableCopy];
        
        [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSLog(@">>G>>");
            
            FZZMessage *message = [FZZMessage parseJSON:obj];
            
            [message setEvent:event];
            [mutMessages setObject:message atIndexedSubscript:idx];
        }];
        
        [event setMessages:[NSOrderedSet orderedSetWithArray:mutMessages]];
    }
    
    NSLog(@">>H>>");
    
    NSLog(@"event after: %@", event);
//    NSLog(@"creator: %@", [event creator]);
    
    return event;
}

+(NSArray *)parseEventJSONList:(NSArray *)eventListJSON{
    if (eventListJSON == NULL){
        return NULL;
    }
    
    NSLog(@">>1");
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:eventListJSON];
    
    [eventListJSON enumerateObjectsUsingBlock:^(id eventJSON, NSUInteger index, BOOL *stop) {
        
        NSLog(@">>2");
        
        FZZEvent *event = [FZZEvent parseJSON:eventJSON];
        
        NSLog(@">>3");
        
        [result setObject:event atIndexedSubscript:index];
    }];
    
    NSLog(@">>4");
    
    return result;
}

+(void)saveObjects{
    NSManagedObjectContext *moc = [FZZCoreDataStore getAppropriateManagedObjectContext];
    
    NSError *error = nil;
    
    NSLog(@"saveObjects 1");
    
    @synchronized(moc){
        NSLog(@"saveObjects 2");
        
        if (![moc save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        NSLog(@"saveObjects 3");
    }
}

+(void)killEvents:(NSArray *)deadEvents{
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
//    NSManagedObjectContext *moc = [FZZCoreDataStore getAppropriateManagedObjectContext];
    
    NSManagedObjectContext *moc = [FZZCoreDataStore getAppropriateManagedObjectContext];
    
    NSLog(@"killEvents 1");
    
    @synchronized(moc){
        NSLog(@"killEvents 2");
        
        [deadEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSNumber *eID = obj;
            
            NSLog(@"killEvents 3");
            
            FZZEvent *event = [events objectForKey:eID];
            [moc deleteObject:event];
            
            NSLog(@"killEvents 4");
            
            [events removeObjectForKey:eID];
        }];
        
        NSLog(@"killEvents 5");
    }
    
    NSLog(@"killEvents 6");
    
    [self saveObjects];
    
    NSLog(@"killEvents 7");
}

-(NSDate *)lastUpdate{
    NSInteger count = [self.messages count];
    
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
    
    NSLog(@"PENIS InsertMessage");
    
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
    
    NSLog(@"PENIS InsertMessages");
    
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
    
    NSLog(@"PENIS AddMessagesObject");
    
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
    
    NSLog(@"PENIS addMessages");
    
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

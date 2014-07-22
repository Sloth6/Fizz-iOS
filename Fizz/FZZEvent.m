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

@property (nonatomic) BOOL haveExpressedInterest;
//@property BOOL haveSeatsChanged;

//@property (strong, nonatomic) NSNumber *numSeats;
//@property (strong, nonatomic) NSNumber *pendingNumSeats;

@property (strong, nonatomic) NSDate *lastUpdate;

@end

@implementation FZZEvent

@synthesize haveExpressedInterest = _haveExpressedInterest;

+(NSDictionary *)getEventsJSONForCache{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:[events count]];
    
    NSDictionary *eventDict = [events copy];
    
    [eventDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        FZZEvent *event = [obj copy];
        
        NSDictionary *jsonEvent = [[NSMutableDictionary alloc] init];
        
        [jsonEvent setValue:[event creationTime] forKey:@"creationTime"];
        
        // Clusters
        NSArray *clusters = [event clusters];
        NSMutableArray *clusterJSONs = [[NSMutableArray alloc] initWithCapacity:[clusters count]];
        
        for (int i = 0; i < [clusters count]; ++i){
            FZZCluster *cluster = [clusters objectAtIndex:i];
            NSArray *userIDs = [cluster userIDs];
            [clusterJSONs addObject:userIDs];
        }
        
        [jsonEvent setValue:[event clusters] forKey:@"clusters"];
        
        // Guests
        NSArray *guests = [event guests];
        NSMutableArray *guestIDs = [[NSMutableArray alloc] initWithCapacity:[guests count]];
        
        for (int i = 0; i < [guests count]; ++i){
            NSNumber *userID = [[guests objectAtIndex:i] userID];
            [guestIDs addObject:userID];
        }
        
        [jsonEvent setValue:guestIDs forKey:@"guests"];
        
        // Invitees
        NSArray *invitees = [event invitees];
        NSMutableArray *inviteeIDs = [[NSMutableArray alloc] initWithCapacity:[invitees count]];
        
        for (int i = 0; i < [invitees count]; ++i){
            NSNumber *userID = [[invitees objectAtIndex:i] userID];
            [inviteeIDs addObject:userID];
        }
        
        [jsonEvent setValue:inviteeIDs forKey:@"invitees"];
        
        // Messages
        NSArray *messages = [event messages];
        NSArray *messageJSONs = [FZZMessage convertMessagesToJSONForCache:messages];
        
        [jsonEvent setValue:messageJSONs forKey:@"messages"];
        
        // Creator
        FZZUser *creator = [event creator];
        [jsonEvent setValue:[creator userID] forKey:@"creator"];
        
        
        // Where key = uID
        [dict setObject:jsonEvent forKey:key];
    }];
    
    return dict;
}

+(void)parseEventsJSONForCache:(NSDictionary *)eventsJSON{
    
    [eventsJSON enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *jsonEvent = obj;
        NSNumber *eventID = key;
        
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        @synchronized(event){
            NSDate *creationTime = [jsonEvent objectForKey:@"creationTime"];
            [event setCreationTime:creationTime];
            
            // Clusters
            NSArray *clusterUserIDs = [jsonEvent objectForKey:@"clusters"];
            NSMutableArray *clusters = [[NSMutableArray alloc] initWithCapacity:[clusterUserIDs count]];
            
            for (int i = 0; i < [clusterUserIDs count]; ++i){
                NSArray *userIDs = [clusterUserIDs objectAtIndex:i];
                FZZCluster *cluster = [FZZCluster clusterFromUserIDs:userIDs];
                
                [clusters addObject:cluster];
            }
            
            [event setClusters:clusters];
            
            // Guests
            NSArray *guestIDs = [jsonEvent objectForKey:@"guests"];
            NSMutableArray *guests = [[NSMutableArray alloc] initWithCapacity:[guestIDs count]];
            
            for (int i = 0; i < [guestIDs count]; ++i){
                NSNumber *userID = [guestIDs objectAtIndex:i];
                
                [guests addObject:[FZZUser userWithUID:userID]];
            }
            
            [event setGuests:guests];
            
            // Invitees
            NSArray *inviteeIDs = [jsonEvent objectForKey:@"invitees"];
            NSMutableArray *invitees = [[NSMutableArray alloc] initWithCapacity:[inviteeIDs count]];
            
            for (int i = 0; i < [inviteeIDs count]; ++i){
                NSNumber *userID = [inviteeIDs objectAtIndex:i];
                
                [invitees addObject:[FZZUser userWithUID:userID]];
            }
            
            [event setInvitees:invitees];
            
            // Messages
            NSArray *messageJSONs = [jsonEvent objectForKey:@"messages"];
            NSArray *messages = [FZZMessage convertMessagesFromJSONForCache:messageJSONs];
            
            [event setMessages:messages];
            
            // Creator
            NSNumber *creatorUserID = [jsonEvent objectForKey:@"creator"];
            FZZUser *creator = [FZZUser userWithUID:creatorUserID];
            
            [event setCreator:creator];
        }
    }];
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

    self = [super init];
    
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
    
    FZZEvent *event = [events objectForKey:eID];
    
    if (event == NULL){
        event = [[FZZEvent alloc] initWithEID:eID];
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
    
    return nil;
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
        [self setClusters:clusters];
    }
}

-(void)updateGuests:(NSArray *)guests{
    @synchronized(self){
        [self setGuests:guests];
    }
}

-(void)updateInvitees:(NSArray *)invitees{
    @synchronized(self){
        [self setInvitees:invitees];
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
        
        NSMutableArray *array = [self.messages mutableCopy];// addObject:message];
        
        NSArray *items = [self.messages sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
            FZZMessage *m1 = obj1;
            FZZMessage *m2 = obj2;
            
            return [[m1 messageID] compare:[m2 messageID]];
        }];
        
        self.messages = items;
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

+(void)killEvents:(NSArray *)deadEvents{
    return true;
    
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

@end

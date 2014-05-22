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

@dynamic creator;
@dynamic creationTime;
@dynamic eventID;

@dynamic invitees;
@dynamic guests;
@dynamic clusters;

@dynamic suggestedInvites;

@dynamic messages;

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
    
    NSEntityDescription *entityDescription = [self getEntityDescription];
    self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
    
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
    
    NSEntityDescription *entityDescription = [self getEntityDescription];
    self = [super initWithEntity:entityDescription insertIntoManagedObjectContext:moc];
    
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
        event = [[FZZEvent alloc] initWithEID:eID];
    }
    
    return event;
}

-(NSNumber *)eventID{
    return self.eventID;
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
    event.creationTime = creationTime;
    
    // load messages if they are contained in the event object
    if (messages != Nil){
        NSMutableArray *mutMessages = [messages mutableCopy];
        
        [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [mutMessages setObject:[FZZMessage parseJSON:obj] atIndexedSubscript:idx];
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

+(void)killEvents:(NSArray *)deadEvents{
    [deadEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *eID = obj;
        
        [events removeObjectForKey:eID];
    }];
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

@end

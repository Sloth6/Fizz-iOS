//
//  FZZEvent.m
//  Fizz
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import "FZZEvent.h"
#import "FZZMessage.h"
#import "FZZUser.h"
#import <CoreLocation/CoreLocation.h>

static NSMutableDictionary *events;

static NSString *FZZ_NEW_EVENT   = @"newEvent";
static NSString *FZZ_JOIN_EVENT  = @"joinEvent";
static NSString *FZZ_LEAVE_EVENT = @"leaveEvent";
static NSString *FZZ_SET_SEAT_CAPACITY = @"setSeatCapacity";
static NSString *FZZ_NEW_INVITES = @"newInvites";
static NSString *FZZ_REQUEST = @"request";


@interface FZZEvent ()

@property (strong, nonatomic) NSNumber *eventID;

@property (strong, nonatomic) FZZUser *creator;

@property NSTimer *seatTimer;

@property (strong, nonatomic) NSMutableArray *presentAtEvent;
@property (strong, nonatomic) NSMutableArray *guests;
@property (strong, nonatomic) NSMutableArray *invitees;

@property (strong, nonatomic) NSMutableSet *inviteesSet;

@property (nonatomic) BOOL haveExpressedInterest;
@property BOOL haveSeatsChanged;

@property (strong, nonatomic) NSNumber *numSeats;
@property (strong, nonatomic) NSNumber *pendingNumSeats;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSDate *lastUpdate;

// A lightly-sorted list of users who are engaged with the event (attending or commenting or both)
//@property (strong, nonatomic) NSMutableArray *engaged;

@end

@implementation FZZEvent

@dynamic eventID;
@dynamic presentAtEvent;
@dynamic guests;
@dynamic invitees;
@dynamic numSeats;
@dynamic messages;
@dynamic lastUpdate;

//@synthesize eventID;

+(void)setupEventClass{
    if (!events){
        events = [[NSMutableDictionary alloc] init];
    }
}

-(id)init{
//    self = [super init];
    
    self = (FZZEvent *)[FZZDataStore insertNewObjectForEntityForName:@"FZZEvent"];
    
    if (self){
        self.haveSeatsChanged = YES;
        self.haveExpressedInterest = NO;
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
    
//    self = [super init];
    self = (FZZEvent *)[FZZDataStore insertNewObjectForEntityForName:@"FZZEvent"];
    
    if (self){
        self.haveSeatsChanged = YES;
        self.eventID = eID;
        [events setObject:self forKey:eID];
    }
    
    return self;
}

#pragma mark Accessors

-(FZZUser *)creator{
    return self.creator;
}

-(NSMutableArray *)messages{
    return self.messages;
}

-(NSMutableArray *)guests{
    return self.guests;
}

-(NSMutableArray *)invitees{
    return self.invitees;
}

-(NSArray *)notYetGuests{
    NSMutableArray *notGuests = [self.invitees mutableCopy];
    
    [notGuests removeObjectsInArray:self.guests];
    
    return [NSArray arrayWithArray:notGuests];
}

//-(NSArray *)engaged{
//    return [self.engaged copy];
//}

-(BOOL)hasSeats{
    return (self.numSeats != nil);
}

-(NSNumber *)pendingNumSeats{
    return self.pendingNumSeats;
}

-(NSNumber *)numSeats{
    return self.numSeats;
}

-(NSNumber *)pendingNumEmptySeats{
    if (!self.numSeats){
        return NULL;
    }
    
    int result = MAX([self.pendingNumSeats integerValue] - [self.guests count], 0);
    
    
    return [NSNumber numberWithInt:result];
}

-(NSNumber *)numEmptySeats{
    if (!self.numSeats){
        return NULL;
    }
    
    int result = MAX([self.numSeats integerValue] - [self.guests count], 0);
    
    return [NSNumber numberWithInt:result];
}

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
    return [self.inviteesSet containsObject:user];
}

-(BOOL)isGuest:(FZZUser *)user{
    return [self.guests containsObject:user];
}

-(BOOL)isAtEvent:(FZZUser *)user{
    return [self.presentAtEvent containsObject:user];
}

-(FZZMessage *)firstMessage{
    if ([self.messages count] > 0){
        return [self.messages objectAtIndex:0];
    }
    
    return NULL;
}

// You can always add a seat
- (void)addSeat{
    @synchronized(self){
        if (self.pendingNumSeats){
            [self restartTimer];
            
            self.haveSeatsChanged = YES;
        
            self.pendingNumSeats = [NSNumber numberWithInt:[self.pendingNumSeats integerValue] + 1];
        }
    }
}

-(void)updateNumberOfSeats:(NSNumber *)numSeats{
    @synchronized(self){
        self.haveSeatsChanged = YES;
        self.numSeats = [numSeats copy];
        self.pendingNumSeats = self.numSeats;
    }
}

-(void)updateRemoveGuest:(FZZUser *)guest{
    @synchronized(self){
        [self.guests removeObject:guest];
    }
}

-(void)updateAtEvent:(NSArray *)attendees{
    @synchronized(self){
        self.presentAtEvent = [attendees mutableCopy];
        
        [self.guests removeObjectsInArray:attendees];
        [self.invitees removeObjectsInArray:attendees];
    }
}

-(void)updateGuests:(NSArray *)guests{
    @synchronized(self){
        self.guests = [guests mutableCopy];
        [self.presentAtEvent removeObjectsInArray:guests];
        [self.invitees removeObjectsInArray:guests];
    }
}

-(void)updateAddInvitees:(NSArray *)invitees{
    @synchronized(self){
        // Ensure no duplicates
        [self.invitees removeObjectsInArray:invitees];
        [self.invitees addObjectsFromArray:invitees];
        
        [self.inviteesSet addObjectsFromArray:invitees];
    }
}

-(void)updateToAttendees:(NSArray *)toAttendees{
    @synchronized(self){
        [self.presentAtEvent removeObjectsInArray:toAttendees];
        [self.guests removeObjectsInArray:toAttendees];
        [self.invitees removeObjectsInArray:toAttendees];
        
        [self.presentAtEvent addObjectsFromArray:toAttendees];
    }
}

-(void)updateToGuests:(NSArray *)toGuests{
    @synchronized(self){
        [self.presentAtEvent removeObjectsInArray:toGuests];
        [self.guests removeObjectsInArray:toGuests];
        [self.invitees removeObjectsInArray:toGuests];
        
        [self.guests addObjectsFromArray:toGuests];
    }
}

-(void)updateToInvitees:(NSArray *)toInvitees{
    @synchronized(self){
        [self.presentAtEvent removeObjectsInArray:toInvitees];
        [self.guests removeObjectsInArray:toInvitees];
        [self.invitees removeObjectsInArray:toInvitees];
        
        [self.invitees addObjectsFromArray:toInvitees];
    }
}

-(void)updateAddMessage:(FZZMessage *)message{
    @synchronized(self){
        [self.messages removeObject:message];
        [self.messages addObject:message];
        
        [self.messages sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
            FZZMessage *m1 = obj1;
            FZZMessage *m2 = obj2;
            
            return [[m1 messageID] compare:[m2 messageID]];
        }];
    }
}

// Attempt to subtract an empty seat. If no empty seats, no subtraction
- (BOOL)removeSeat{
    @synchronized(self){
        [self restartTimer];
        
        int pendingNumSeats = [self.pendingNumSeats integerValue];
        int numOccupiedSeats = [self.guests count];
        
        if (pendingNumSeats > numOccupiedSeats){
            self.haveSeatsChanged = YES;
            self.pendingNumSeats = [NSNumber numberWithInt:pendingNumSeats - 1];
            
            return YES;
        } else {
            return NO;
        }
    }
}

-(BOOL)expressInterest{
    FZZUser *me = [FZZUser me];
    
    if ([self isInvited:me]){
        return NO;
    }
    
    if (self.haveExpressedInterest){
        return NO;
    }
    
    self.haveExpressedInterest = YES;
    
    [self socketIORequestEventWithAcknowledge:NULL];
    
    return YES;
}

-(BOOL)haveExpressedInterest{
    return self.haveExpressedInterest;
}

-(BOOL)joinEvent{
    FZZUser *me = [FZZUser me];
    
    if ([self isGuest:me] || ![self isInvited:me]){
        return NO;
    }
    
    [self updateAddGuest:me];
    [self socketIOJoinEventWithAcknowledge:NULL];
    
    return YES;
}

-(BOOL)leaveEvent{
    FZZUser *me = [FZZUser me];
    
    if (![self isGuest:me]){
        return NO;
    }
    
    [self updateRemoveGuest:me];
    [self socketIOLeaveEventWithAcknowledge:NULL];
    
    return YES;
}

-(void)updateAddGuest:(FZZUser *)guest{
    @synchronized(self){
        if (![self.guests containsObject:guest]){
            [self.guests addObject:guest];
        }
    }
}

-(void)updateAddAtEvent:(NSArray *)arrivingList{
    @synchronized(self){
        [arrivingList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FZZUser *user = obj;
            
            if (![self.presentAtEvent containsObject:user]){
                [self.presentAtEvent addObject:user];
            }
        }];
    }
}

-(void)updateRemoveAtEvent:(NSArray *)leavingList{
    @synchronized(self){
        [leavingList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            FZZUser *user = obj;
            
            if ([self.presentAtEvent containsObject:user]){
                [self.presentAtEvent removeObject:user];
            }
        }];
    }
}

-(BOOL)haveSeatsChangedSinceLastCheck{
    BOOL result = self.haveSeatsChanged;
    
    self.haveSeatsChanged = NO;
    
    return result;
}

- (void)pushSeatsToServer{
    self.seatTimer = NULL;
    
    // Don't send anything if nothing has changed
    if ([self.numSeats isEqualToNumber:self.pendingNumSeats]){
        return;
    }
    
    self.numSeats = self.pendingNumSeats;
    
    // Perform the push to the server
    [self socketIOSetSeatCapacityToCapacity:self.numSeats
                            WithAcknowledge:nil];
}

// Call this every time the seats change, it ensures 1.6 second after the last seat change
// The data will be pushed to the server if need be
// Avoids spamming the server
- (void)restartTimer{
    [self.seatTimer invalidate];
    
    self.seatTimer = [NSTimer scheduledTimerWithTimeInterval:1.6
                                                  target:self
                                                selector:@selector(pushSeatsToServer)
                                                userInfo:nil
                                                 repeats:NO];
}


-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:self.eventID forKey:@"eid"];
    
//    FZZSocketIODelegate *socketIODelegate = [FZZSocketIODelegate getIOSocketDelegate];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_JOIN_EVENT withData:json andAcknowledge:function];
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
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_INVITES withData:json andAcknowledge:function];
}

-(void)socketIORequestEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_REQUEST withData:json andAcknowledge:function];
}

-(void)socketIOSetSeatCapacityToCapacity:(NSNumber *)capacity
                         WithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    /* seats : int */
    [json setObject:capacity forKey:@"seats"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_SET_SEAT_CAPACITY withData:json andAcknowledge:function];
}

+(void)socketIONewEventWithMessage:(NSString *)message
                          AndSeats:(int)numSeats
                    AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* seats : int */
    [json setObject:[NSNumber numberWithInt:numSeats] forKey:@"seats"];
    
    /* text : string */
    [json setObject:message forKey:@"text"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_EVENT withData:json andAcknowledge:function];
}

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
    
    
    /* Present At Event uID List */
    NSMutableArray *mutPresentAtEventList;
    
    NSArray *presentAtEventIDList = [eventJSON objectForKey:@"presentAtEventList"];
    
    mutPresentAtEventList = [presentAtEventIDList mutableCopy];
    
    // Map JSON Parsing
    [mutPresentAtEventList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *uid = (NSNumber *)obj;
        
        FZZUser *user = [FZZUser userWithUID:uid];
        
        [mutPresentAtEventList setObject:user
                        atIndexedSubscript:idx];
    }];
    
    presentAtEventIDList = nil;
    
    
    /* Guest uID List */
    NSMutableArray *mutGuestList;

    NSArray *guestIDList = [eventJSON objectForKey:@"guestList"];
    
    mutGuestList = [guestIDList mutableCopy];
    
    // Map JSON Parsing
    [guestIDList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *uid = (NSNumber *)obj;
        
        FZZUser *user = [FZZUser userWithUID:uid];
        
        [mutGuestList setObject:user
             atIndexedSubscript:idx];
    }];
    
    guestIDList = nil;
    
    
    /* All invited individuals, as User Object JSONs */
    NSMutableArray *mutInviteList;
    
    NSArray *inviteJSONList = [eventJSON objectForKey:@"inviteList"];
    
    mutInviteList = [inviteJSONList mutableCopy];
    
    // Map JSON Parsing
    [inviteJSONList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZUser *user = [FZZUser parseJSON:obj];
        
        [mutInviteList setObject:user
              atIndexedSubscript:idx];
    }];
    
    inviteJSONList = nil;
    
    
    /* Seats */
    NSNumber *numSeats = [eventJSON objectForKey:@"seats"];
    
    
    /* Message List */
    NSMutableArray *mutMessageList;
    NSArray *messageJSONList = [eventJSON objectForKey:@"messageList"];
        
    mutMessageList = [messageJSONList mutableCopy];

    
    // Map JSON Parsing
    [messageJSONList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZMessage *message = [FZZMessage parseJSON:obj];
        
        [mutMessageList setObject:message
              atIndexedSubscript:idx];
    }];
    
    
    /* Allocate Memory and Assign Values */
    FZZEvent *event = [FZZEvent eventWithEID:eid];
    event.creator = creator;
    event.guests = mutGuestList;
    event.invitees = mutInviteList;
    event.presentAtEvent = mutPresentAtEventList;
    event.inviteesSet = [NSMutableSet setWithArray:mutInviteList];
    
    // NULL if no seats required
    event.numSeats = numSeats;
    event.pendingNumSeats = event.numSeats;
    
    event.messages = mutMessageList;
    
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

-(NSDate *)lastUpdate{
    int count = [self.messages count];
    
    if (count != 0){ // Should always be > 0
        FZZMessage *message = [self.messages objectAtIndex:count - 1];
        
        return [message timestamp];
    }
    
    return [NSDate distantPast];
}

@end

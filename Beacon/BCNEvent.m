//
//  BCNEvent.m
//  Beacon
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import "BCNEvent.h"
#import "BCNMessage.h"
#import "BCNUser.h"
#import <CoreLocation/CoreLocation.h>

static NSMutableDictionary *events;

static NSString *BCN_NEW_EVENT   = @"newEvent";
static NSString *BCN_JOIN_EVENT  = @"joinEvent";
static NSString *BCN_LEAVE_EVENT = @"leaveEvent";
static NSString *BCN_SET_SEAT_CAPACITY = @"setSeatCapacity";
static NSString *BCN_INVITE  = @"invite";
static NSString *BCN_REQUEST = @"request";


@interface BCNEvent ()

@property (strong, nonatomic) NSNumber *eventID;

@property (strong, nonatomic) BCNUser *creator;

@property (nonatomic) int numSeats;
@property (nonatomic) int pendingNumSeats;

@property (nonatomic) BOOL haveExpressedInterest;
@property BOOL haveSeatsChanged;

@property NSTimer *seatTimer;


@property (strong, nonatomic) NSMutableArray *attendees;
@property (strong, nonatomic) NSMutableArray *invitees;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSDate *lastUpdate;
@property BOOL inviteOnly;

// A lightly-sorted list of users who are engaged with the event (attending or commenting or both)
//@property (strong, nonatomic) NSMutableArray *engaged;

@end

@implementation BCNEvent

@synthesize attendees, eventID;

+(void)setupEventClass{
    if (!events){
        events = [[NSMutableDictionary alloc] init];
    }
}

-(id)init{
    self = [super init];
    
    if (self){
        _haveSeatsChanged = YES;
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
    
    self = [super init];
    
    if (self){
        _haveSeatsChanged = YES;
        self.eventID = eID;
        [events setObject:self forKey:eID];
    }
    
    return self;
}

#pragma mark Accessors

-(BCNUser *)creator{
    return _creator;
}

-(NSArray *)messages{
    // Autoreleased
    return [NSArray arrayWithArray:_messages];
}

-(NSArray *)attendees{
    // Autoreleased
    return [NSArray arrayWithArray:attendees];
}

-(NSArray *)notYetAttending{
    NSMutableArray *notAttending = [_invitees mutableCopy];
    
    [notAttending removeObjectsInArray:attendees];
    
    return [NSArray arrayWithArray:notAttending];
}

//-(NSArray *)engaged{
//    return [_engaged copy];
//}

-(int)numSeats{
    return _numSeats;
}

-(int)pendingNumSeats{
    return _pendingNumSeats;
}

-(int)pendingNumEmptySeats{
    return MAX(_pendingNumSeats - [attendees count], 0);
}

-(int)numEmptySeats{
    return MAX(_numSeats - [attendees count], 0);
}

+(BCNEvent *)eventWithEID:(NSNumber *)eID{
    if (!eID) return NULL;
    
    BCNEvent *event = [events objectForKey:eID];
    
    if (event == NULL){
        event = [[BCNEvent alloc] initWithEID:eID];
    }
    
    return event;
}

-(NSNumber *)eventID{
    return eventID;
}

-(BOOL)isInviteOnly{
    return _inviteOnly;
}

-(BOOL)isInvited:(BCNUser *)user{
    return [_invitees containsObject:user];
}

-(BOOL)isAttending:(BCNUser *)user{
    return [attendees containsObject:user];
}

-(BCNMessage *)firstMessage{
    if ([_messages count] > 0){
        return [_messages objectAtIndex:0];
    }
    
    return NULL;
}

// You can always add a seat
- (void)addSeat{
    [self restartTimer];
    
    _haveSeatsChanged = YES;
    _pendingNumSeats++;
}

-(void)updateNumberOfSeats:(NSNumber *)numSeats{
    @synchronized(self){
        _haveSeatsChanged = YES;
        _numSeats = [numSeats integerValue];
        _pendingNumSeats = _numSeats;
    }
}

-(void)updateRemoveGuest:(BCNUser *)guest{
    @synchronized(self){
        [attendees removeObject:guest];
    }
}

-(void)updateInvites:(NSArray *)invites{
    @synchronized(self){
        // Ensure no duplicates
        [_invitees removeObjectsInArray:invites];
        [_invitees addObjectsFromArray:invites];
    }
}

-(void)updateAddMessage:(BCNMessage *)message{
    @synchronized(self){
        [_messages removeObject:message];
        [_messages addObject:message];
        
        [_messages sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
            BCNMessage *m1 = obj1;
            BCNMessage *m2 = obj2;
            
            return [[m1 messageID] compare:[m2 messageID]];
        }];
    }
}

// Attempt to subtract an empty seat. If no empty seats, no subtraction
- (BOOL)removeSeat{
    [self restartTimer];
    
    int numOccupiedSeats = [attendees count];
    
    if (_pendingNumSeats > numOccupiedSeats){
        _haveSeatsChanged = YES;
        _pendingNumSeats--;
        
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)expressInterest{
    BCNUser *me = [BCNUser me];
    
    if ([self isInvited:me]){
        return NO;
    }
    
    if (_haveExpressedInterest){
        return NO;
    }
    
    _haveExpressedInterest = YES;
    
    [self socketIORequestEventWithAcknowledge:NULL];
    
    return YES;
}

-(BOOL)haveExpressedInterest{
    return _haveExpressedInterest;
}

-(BOOL)joinEvent{
    BCNUser *me = [BCNUser me];
    
    if ([self isAttending:me] || ![self isInvited:me]){
        return NO;
    }
    
    [self updateAddGuest:me];
    [self socketIOJoinEventWithAcknowledge:NULL];
    
    return YES;
}

-(BOOL)leaveEvent{
    BCNUser *me = [BCNUser me];
    
    if (![self isAttending:me]){
        return NO;
    }
    
    [self updateRemoveGuest:me];
    [self socketIOLeaveEventWithAcknowledge:NULL];
    
    return YES;
}

-(void)updateAddGuest:(BCNUser *)guest{
    @synchronized(self){
        if (![attendees containsObject:guest]){
            [attendees addObject:guest];
        }
    }
}

-(BOOL)haveSeatsChangedSinceLastCheck{
    BOOL result = _haveSeatsChanged;
    
    _haveSeatsChanged = NO;
    
    return result;
}

- (void)pushSeatsToServer{
    _seatTimer = NULL;
    
    // Don't send anything if nothing has changed
    if (_numSeats == _pendingNumSeats){
        return;
    }
    
    _numSeats = _pendingNumSeats;
    
    // Perform the push to the server
    [self socketIOSetSeatCapacityToCapacity:_numSeats
                            WithAcknowledge:nil];
}

// Call this every time the seats change, it ensures 1.6 second after the last seat change
// The data will be pushed to the server if need be
// Avoids spamming the server
- (void)restartTimer{
    [_seatTimer invalidate];
    
    _seatTimer = [NSTimer scheduledTimerWithTimeInterval:1.6
                                                  target:self
                                                selector:@selector(pushSeatsToServer)
                                                userInfo:nil
                                                 repeats:NO];
}


-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:eventID forKey:@"eid"];
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_JOIN_EVENT withData:json andAcknowledge:function];
}

/*-(void)socketIODeleteEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    // id : int
    [json setObject:eventID forKey:@"id"];
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_DELETE_EVENT withData:json andAcknowledge:function];
}*/

-(void)socketIOLeaveEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:eventID forKey:@"eid"];
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_LEAVE_EVENT withData:json andAcknowledge:function];
}

-(void)socketIOInviteWithInviteList:(NSArray *)inviteList
                    InviteContactList:(NSArray *)contactList
                     AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* inviteList : user array */
    {
        NSArray *userArray = [BCNUser usersToJSONUsers:inviteList];
        [json setObject:userArray forKey:@"inviteList"];
    }
    
    /* invitePnList : string array */
    // Any user without a UID, send their phone number
    [json setObject:contactList forKey:@"invitePnList"];
    
    /* id : int */
    [json setObject:eventID forKey:@"eid"];
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_INVITE withData:json andAcknowledge:function];
}

-(void)socketIORequestEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:eventID forKey:@"eid"];
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_REQUEST withData:json andAcknowledge:function];
}

-(void)socketIOSetSeatCapacityToCapacity:(int)capacity
                            WithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:eventID forKey:@"eid"];
    
    /* seats : int */
    [json setObject:[NSNumber numberWithInt:capacity] forKey:@"seats"];
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_SET_SEAT_CAPACITY withData:json andAcknowledge:function];
}

+(void)socketIONewEventWithMessage:(NSString *)message
                        InviteOnly:(BOOL)isInviteOnly
                    AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* inviteOnly : BOOL */
    [json setObject:[NSNumber numberWithBool:isInviteOnly] forKey:@"inviteOnly"];
    
    /* text : string */
    [json setObject:message forKey:@"text"];
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_NEW_EVENT withData:json andAcknowledge:function];
}

/*-(NSArray *)getJsonComments{
    NSMutableArray *json = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [comments count]; i++){
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        BCNComment *comment = [comments objectAtIndex:i];
        
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
    int numComments    = [_messages count];
    
    for (int j = 0; j < numComments; j++){
        BCNMessage *message = [_messages objectAtIndex:j];
        BCNUser    *user    = [message user];
        
        if (![seenUsers containsObject:user]){
            [seenUsers addObject:user];
            [uniqueUsers addObject:user];
            numUniqueUsers++;
        }
    }
    
    return uniqueUsers;
}

-(NSMutableArray *)takeCommentingAttendeesFromCommenters:(NSMutableArray *)uCommenters
                                     andAttendees:(NSMutableArray *)uAttendees{
    NSSet *attendeesSet = [NSSet setWithArray:uAttendees];
    int numCommenters = [uCommenters count];
    int count = 0;
    
    NSMutableArray *commentingAttendees = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < numCommenters; ++i){
        BCNUser *user = [uCommenters objectAtIndex:i];
        if ([attendeesSet containsObject:user]){
            [commentingAttendees addObject:user];
            [uCommenters removeObject:user];
            [uAttendees removeObject:user];
            ++count;
        }
    }
    
    return commentingAttendees;
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
//    _engaged = engagedTemp;
//}

+(BCNEvent *)parseJSON:(NSDictionary *)eventJSON{
    if (eventJSON == NULL){
        return NULL;
    }
    
    /* Event ID */
    NSNumber *eid = [eventJSON objectForKey:@"eid"];
    
    /* Creator uID */
    BCNUser *creator;
    {
        NSNumber *creatorUID = [eventJSON objectForKey:@"creator"];
        creator = [BCNUser userWithUID:creatorUID];
    }
    
    /* Guest uID List */
    NSMutableArray *mutGuestList;

    NSArray *guestIDList = [eventJSON objectForKey:@"guestList"];
    
    mutGuestList = [guestIDList mutableCopy];
    
    // Map JSON Parsing
    [guestIDList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *uid = (NSNumber *)obj;
        
        BCNUser *user = [BCNUser userWithUID:uid];
        
        [mutGuestList setObject:user
             atIndexedSubscript:idx];
    }];
    
    /* All invited individuals, as User Object JSONs */
    NSMutableArray *mutInviteList;
    
    NSArray *inviteJSONList = [eventJSON objectForKey:@"inviteList"];
    
    mutInviteList = [inviteJSONList mutableCopy];
    
    NSLog(@"\n\n%@\n\n", mutInviteList);
    
    // Map JSON Parsing
    [inviteJSONList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BCNUser *user = [BCNUser parseJSON:obj];
        
        [mutInviteList setObject:user
              atIndexedSubscript:idx];
    }];
    
    /* Seats */
    NSNumber *numSeats = [eventJSON objectForKey:@"seats"];
    
    /* Message List */
    NSMutableArray *mutMessageList;
    NSArray *messageJSONList = [eventJSON objectForKey:@"messageList"];
        
    mutMessageList = [messageJSONList mutableCopy];

    
    // Map JSON Parsing
    [messageJSONList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BCNMessage *message = [BCNMessage parseJSON:obj];
        
        [mutMessageList setObject:message
              atIndexedSubscript:idx];
    }];
    
    /* Invite Only */
    NSNumber *inviteOnly = [eventJSON objectForKey:@"inviteOnly"];
    
    /* Allocate Memory and Assign Values */
    BCNEvent *event = [BCNEvent eventWithEID:eid];
    event.creator = creator;
    event.attendees = mutGuestList;
    event.invitees = mutInviteList;
    event.numSeats = [numSeats integerValue];
    event.pendingNumSeats = event.numSeats;
    event.messages = mutMessageList;
    event.inviteOnly = [inviteOnly boolValue];
    
    return event;
}

+(NSArray *)parseEventJSONList:(NSArray *)eventArray{
    if (eventArray == NULL){
        return NULL;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:eventArray];
    
    [eventArray enumerateObjectsUsingBlock:^(id eventJSON, NSUInteger index, BOOL *stop) {
        BCNEvent *event = [BCNEvent parseJSON:eventJSON];
        [result setObject:event atIndexedSubscript:index];
    }];
    
    return result;
}

-(NSDate *)lastUpdate{
    int count = [self.messages count];
    
    if (count != 0){ // Should always be > 0
        BCNMessage *message = [_messages objectAtIndex:count - 1];
        
        return [message timestamp];
    }
    
    return [NSDate distantPast];
}

@end

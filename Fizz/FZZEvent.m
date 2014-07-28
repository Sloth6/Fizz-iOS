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

#import "FZZLocalCache.h"

static NSMutableDictionary *events;

static NSString *FZZ_NEW_EVENT    = @"postNewEvent";
static NSString *FZZ_DELETE_EVENT = @"postDeleteEvent";
static NSString *FZZ_JOIN_EVENT   = @"postJoinEvent";
static NSString *FZZ_LEAVE_EVENT  = @"postLeaveEvent";
static NSString *FZZ_NEW_INVITES  = @"postNewInvites";
static NSString *FZZ_UPDATE_EVENT = @"postUpdateEvent";
static NSString *FZZ_REQUEST_EVENTS = @"postRequestEvents";


@interface FZZEvent ()


@property (nonatomic) BOOL haveExpressedInterest;

@property (strong, nonatomic) NSDate *lastUpdate;

@end

@implementation FZZEvent

@synthesize haveExpressedInterest = _haveExpressedInterest;

+(BOOL)saveEventsToFile:(NSString *)eventsURL{
    NSDictionary *jsonDict = [FZZEvent getEventsJSONForCache];
    return [jsonDict writeToFile:eventsURL atomically:YES];
}

+(NSDictionary *)getEventsJSONForCache{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:[events count]];
    
    NSDictionary *eventDict = [events copy];
    
    [eventDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        FZZEvent *event = obj;
        
        NSDictionary *jsonEvent = [[NSMutableDictionary alloc] init];
        
        [jsonEvent setValue:[event creationTime] forKey:@"creationTime"];
        
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

/*
 For each cached event, loads the cached event data, provided the event doesn't exist in the app already.
 
 Should only be called AFTER parseUsersJSONForCache
 */
+(void)parseEventsJSONForCache:(NSDictionary *)eventsJSON{
    
    [eventsJSON enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *jsonEvent = obj;
        NSNumber *eventID = key;
        
        BOOL eventExists = [events objectForKey:eventID] != nil;
        
        if (!eventExists){
            FZZEvent *event = [FZZEvent eventWithEID:eventID];
            
            @synchronized(event){
                NSDate *creationTime = [jsonEvent objectForKey:@"creationTime"];
                [event setCreationTime:creationTime];
                
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

// Guests are Absolute because you can choose to leave an event at any time
-(void)updateGuests:(NSArray *)guests{
    @synchronized(self){
        [self setGuests:guests];
    }
}

// Invitees are Additive because you can't be uninvited from an event
-(void)updateAddInvitees:(NSArray *)invitees{
    @synchronized(self){
        NSMutableArray *resultInvitees = [[self invitees] mutableCopy];
        [resultInvitees addObjectsFromArray:invitees];
        
        [self setInvitees:resultInvitees];
    }
}


-(void)updateAddMessage:(FZZMessage *)message{
    @synchronized(self){
        
        if (!self.messages){
            self.messages = [[NSArray alloc] init];
        }
        
        NSArray *items = [self.messages sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
            FZZMessage *m1 = obj1;
            FZZMessage *m2 = obj2;
            
            return [[m1 messageID] compare:[m2 messageID]];
        }];
        
        self.messages = items;
    }
}

-(void)updateDescription:(NSString *)description{
    @synchronized(self){
        [self setDescription:description];
    }
}

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
        
        NSMutableArray *guests = [[self guests] mutableCopy];
        [guests removeObject:me];
        [self setGuests:guests];
    }
    
    [self socketIOLeaveEventWithAcknowledge:NULL];
    
    return YES;
}

-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_JOIN_EVENT withData:json andAcknowledge:function];
}

-(void)socketIOLeaveEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_LEAVE_EVENT withData:json andAcknowledge:function];
}

-(void)socketIOInviteWithInviteList:(NSArray *)inviteList
                     AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* eid : int */
    [json setObject:self.eventID forKey:@"eid"];
    
    /* inviteList : {name : string, pn :string} array */
    [json setObject:inviteList forKey:@"inviteList"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_INVITES withData:json andAcknowledge:function];
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

-(void)socketIOUpdateEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* eid : int */
    [json setObject:[self eventID] forKey:@"eid"];
    
    /* descriptions : string */
    [json setObject:[self description] forKey:@"description"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_UPDATE_EVENT withData:json andAcknowledge:function];
}

-(void)socketIOUpdateEventWithEventsList:(NSArray *)events
                          AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    NSMutableArray *eventIDs = [events mutableCopy];
    
    [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZEvent *event = obj;
        NSNumber *eventID = [event eventID];
        
        [eventIDs setObject:eventID atIndexedSubscript:idx];
    }];
    
    /* eidList : int array */
    [json setObject:eventIDs forKey:@"eidList"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_REQUEST_EVENTS
                                     withData:json
                               andAcknowledge:function];
}

+(void)socketIONewEventWithMessage:(NSString *)message
                    AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* description : string */
    [json setObject:message forKey:@"description"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_EVENT withData:json andAcknowledge:function];
}

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
    NSNumber *creationTimeInterval = [eventJSON objectForKey:@"creationTime"];
    
    NSDate *creationTime = [NSDate dateWithTimeIntervalSince1970:[creationTimeInterval longValue]];
    
    NSArray *messages = [eventJSON objectForKey:@"messages"];
    
    NSArray *inviteJSONs = [eventJSON objectForKey:@"invites"];
    NSArray *invites = [FZZUser parseUserJSONList:inviteJSONs];
    
    NSArray *guestIDs = [eventJSON objectForKey:@"guests"];
    NSMutableArray *guests = [guestIDs mutableCopy];
    
    [guestIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *userID = obj;
        
        FZZUser *user = [FZZUser userWithUID:userID];
        
        [guests setObject:user atIndexedSubscript:idx];
    }];
    
    NSString *description = [eventJSON objectForKey:@"description"];
    
    /* Allocate Memory and Assign Values */
    FZZEvent *event = [FZZEvent eventWithEID:eid];
    
    [event setCreator:creator];
    [event setCreationTime:creationTime];
    
    [event setDescription:description];
    [event setInvitees:invites];
    [event setGuests:guests];
    
    // load messages if they are contained in the event object
    if ((NSObject *)messages != [NSNull null]){
        NSMutableArray *mutMessages = [messages mutableCopy];
        
        [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            FZZMessage *message = [FZZMessage parseJSON:obj];
            
            [message setEvent:event];
            [mutMessages setObject:message atIndexedSubscript:idx];
        }];
        
        [event setMessages:mutMessages];
    }
    
    return event;
}

+(NSArray *)parseEventIDList:(NSArray *)eventIDList{
    if (eventIDList == NULL){
        return NULL;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:eventIDList];
    
    [eventIDList enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        
        NSNumber *eventID = obj;
        
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        [result setObject:event atIndexedSubscript:index];
    }];
    
    return result;
}

+(void)killEvents:(NSArray *)deadEvents{
    NSLog(@"killEvents 1");
    
    [deadEvents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSNumber *eID = obj;
        
        NSLog(@"killEvents 2");
        
        [events removeObjectForKey:eID];
    }];
    
    NSLog(@"killEvents 3");
    
    [FZZLocalCache updateCache];
    
    NSLog(@"killEvents 4");
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

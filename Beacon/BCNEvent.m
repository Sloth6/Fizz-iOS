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


@interface BCNEvent ()

@property (strong, nonatomic) NSNumber *eventID;

@property (strong, nonatomic) BCNUser *host;

@property (strong, nonatomic) NSMutableArray *attendees;
@property (strong, nonatomic) NSMutableArray *invitees;
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSDate *lastUpdate;

// A lightly-sorted list of users who are engaged with the event (attending or commenting or both)
@property (strong, nonatomic) NSMutableArray *engaged;

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
    }
    
    return self;
}

-(void)dealloc {
    [events removeObjectForKey:self.eventID];
}

-(id)initWithEID:(NSNumber *)eID{
    self = [super init];
    
    if (self){
        [events setObject:self forKey:eID];
    }
    
    return self;
}

#pragma mark Accessors

-(BCNUser *)host{
    return _host;
}

-(NSArray *)messages{
    return [_messages copy];
}

-(NSArray *)attendees{
    return [attendees copy];
}

-(NSArray *)engaged{
    return [_engaged copy];
}

+(BCNEvent *)eventWithEID:(NSNumber *)eID{
    BCNEvent *event = [events objectForKey:eID];
    
    return event;
}

-(NSNumber *)eventID{
    return eventID;
}

-(void)socketIOJoinEventWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* id : int */
    [json setObject:eventID forKey:@"id"];
    
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
    [json setObject:eventID forKey:@"id"];
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_LEAVE_EVENT withData:json andAcknowledge:function];
}

+(void)socketIONewEventWithMessage:(NSString *)message
                        InviteList:(NSArray *)inviteList
                   InvitePhoneList:(NSArray *)phoneList
                    AndAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* creationTime : int */
    NSNumber *creationTime;
    {
        NSTimeInterval timeInterval =
        [NSDate timeIntervalSinceReferenceDate];

        NSInteger integerTime = round(timeInterval);
            creationTime = [NSNumber numberWithInt:integerTime];
    }

    [json setObject:creationTime forKey:@"creationTime"];
    
    /* inviteList : user.uid array */
    {
        NSArray *uids = [BCNUser getUserIDsFromUsers:inviteList];
        [json setObject:uids forKey:@"inviteList"];
    }
    
    /* invitePnList : string array */
    // Any user without a UID, send their phone number
    [json setObject:phoneList forKey:@"invitePnList"];
    
    /* message : string */
    [json setObject:message forKey:@"message"];
    
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

-(void)updateEngaged{
    NSMutableArray *uniqueCommenters = [self getArrayOfUniqueCommenters];
    
    NSMutableArray *uniqueAttendees = [attendees copy];
    
    // Removes commentingAttendees from uniqueCommenters and attendees
    NSMutableArray *commentingAttendees = [self takeCommentingAttendeesFromCommenters:uniqueCommenters
                                                                         andAttendees:uniqueAttendees];
    
    NSMutableArray *engagedTemp = commentingAttendees;
    
    [engagedTemp addObjectsFromArray:uniqueCommenters];
    [engagedTemp addObjectsFromArray:uniqueAttendees];
    
    _engaged = engagedTemp;
}

+(BCNEvent *)parseJSON:(NSDictionary *)eventJSON{
    if (eventJSON == NULL){
        return NULL;
    }
    
    /* Event ID */
    NSNumber *eid = [eventJSON objectForKey:@"eid"];
    
    /* Host uID */
    BCNUser *host;
    {
        NSNumber *hostUID = [eventJSON objectForKey:@"host"];
        host = [BCNUser userWithUID:hostUID];
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
    
    // Map JSON Parsing
    [inviteJSONList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BCNUser *user = [BCNUser parseJSON:obj];
        
        [mutInviteList setObject:user
              atIndexedSubscript:idx];
    }];
    
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
    
    /* Allocate Memory and Assign Values */
    BCNEvent *event = [[BCNEvent alloc] init];
    event.eventID = eid;
    event.host = host;
    event.attendees = mutGuestList;
    event.invitees = mutInviteList;
    event.messages = mutMessageList;
    
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

//
//  FZZMessage.m
//  Fizz
//
//  Created by Andrew Sweet on 5/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZMessage.h"
#import "FZZCoordinate.h"
#import "FZZEvent.h"
#import "FZZUser.h"
#import "FZZSocketIODelegate.h"
#import "FZZAppDelegate.h"

static NSString *FZZ_NEW_MESSAGE = @"newMessage";

@implementation FZZMessage

+(NSArray *)convertMessagesFromJSONForCache:(NSArray *)messageJSONs{
    NSMutableArray *result = [messageJSONs mutableCopy];
    
    [messageJSONs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *jsonMessage = obj;
        
        NSDate *creationTime = [jsonMessage objectForKey:@"creationTime"];
        NSNumber *messageID = [jsonMessage objectForKey:@"messageID"];
        NSString *text = [jsonMessage objectForKey:@"text"];
        
        // Event
        NSNumber *eventID = [jsonMessage objectForKey:@"event"];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        // Marker
        NSDictionary *jsonMarker = [jsonMessage objectForKey:@"marker"];
        FZZCoordinate *marker = [FZZCoordinate fromDictionaryForCache:jsonMarker];
        
        // User
        NSNumber *userID = [jsonMessage objectForKey:@"user"];
        FZZUser *user = [FZZUser userWithUID:userID];
        
        FZZMessage *message;
        
        if (marker == nil){
            message = [[FZZMessage alloc] initWithMID:messageID
                                                 User:user
                                            AndMarker:marker
                                             ForEvent:event];
        } else {
            message = [[FZZMessage alloc] initWithMID:messageID
                                                 User:user
                                              AndText:text
                                             ForEvent:event];
        }
        
        [message setCreationTime:creationTime];
        
        [result setObject:message atIndexedSubscript:idx];
    }];
    
    return result;
}

+(NSArray *)convertMessagesToJSONForCache:(NSArray *)messages{
    NSMutableArray *result = [messages mutableCopy];
    
    NSArray *messagesArray = [result copy];
    
    [messagesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZMessage *message = [obj copy];
        
        NSDictionary *jsonMessage = [[NSMutableDictionary alloc] init];
        
        [jsonMessage setValue:[message creationTime] forKey:@"creationTime"];
        [jsonMessage setValue:[message messageID] forKey:@"messageID"];
        [jsonMessage setValue:[message text] forKey:@"text"];
        
        // Event
        NSNumber *eventID = [[message event] eventID];
        [jsonMessage setValue:eventID forKey:@"event"];
        
        // Marker
        NSDictionary *markerDict = [[message marker] asDictionaryForCache];
        [jsonMessage setValue:markerDict forKey:@"marker"];
        
        // User
        NSNumber *userID = [[message user] userID];
        [jsonMessage setValue:userID forKey:@"user"];
        
        [result setObject:jsonMessage atIndexedSubscript:idx];
    }];
    
    return result;
}

-(id)initWithMID:(NSNumber *)mID User:(FZZUser *)inputUser AndText:(NSString *)inputText ForEvent:(FZZEvent *)inputEvent{
    
    self = [super init];
    
    if (self){
        self.messageID = mID;
        self.user   = inputUser;
        self.text   = inputText;
        self.marker = nil;
        self.event = inputEvent;
        
        [inputEvent addMessage:self];
    }
    
    return self;
}

-(id)initWithMID:(NSNumber *)mID User:(FZZUser *)inputUser AndMarker:(FZZCoordinate *)marker ForEvent:(FZZEvent *)inputEvent{
    self = [super init];
    
    if (self){
        self.messageID = mID;
        self.user   = inputUser;
        self.text   = nil;
        self.marker = marker;
        self.event = inputEvent;
        
        [inputEvent addMessage:self];
    }
    
    return self;
}

+(void)socketIONewMessage:(NSString *)text
                 ForEvent:(FZZEvent *)event
          WithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* eid : int */
    [json setObject:[event eventID] forKey:@"eid"];
    
    /* message : string */
    [json setObject:text forKey:@"text"];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_NEW_MESSAGE withData:json andAcknowledge:function];
}

+(FZZMessage *)parseJSON:(NSDictionary *)messageJSON{
    if (messageJSON == NULL){
        return NULL;
    }
    
    // Message ID
    NSNumber *mid = [messageJSON objectForKey:@"mid"];
    
    // Event ID (Event this message belongs to)
    FZZEvent *event;
    
    NSNumber *eid = [messageJSON objectForKey:@"eid"];
    event = [FZZEvent eventWithEID:eid];
    
    // User ID of the message poster
    FZZUser *user;
    
    NSNumber *uid = [messageJSON objectForKey:@"uid"];
    
    switch ([uid integerValue]) {
        case -1:
            user = NULL;
            break;
            
        default:
            user = [FZZUser userWithUID:uid];
            break;
    }
    
    // Text of the message sent
    NSString *text = [messageJSON objectForKey:@"text"];
    
    FZZCoordinate *marker;
    
    if (!text){
        marker = [FZZCoordinate parseJSON:[messageJSON objectForKey:@"marker"]];
    }
    
    // When this message was created
    NSDate *creationTime;
    
    NSNumber *creationTimeNum = [messageJSON objectForKey:@"creationTime"];
    creationTime = [NSDate dateWithTimeIntervalSince1970:[creationTimeNum integerValue]];
    
    
    FZZMessage *message;
    
    // Message can either contain a marker or text
    if (text){
        message = [[FZZMessage alloc] initWithMID:mid
                                             User:user
                                          AndText:text
                                         ForEvent:event];
    } else {
        message = [[FZZMessage alloc] initWithMID:mid
                                             User:user
                                        AndMarker:marker
                                         ForEvent:event];
    }
    
    message.creationTime = creationTime;
    
    return message;
}

+(NSDictionary *)parseMessageJSONDict:(NSDictionary *)messageDictJSON{
    
    if (messageDictJSON == NULL){
        return NULL;
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:[messageDictJSON count]];
    
    [messageDictJSON enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *eidString = key;
        NSNumber *eid = [NSNumber numberWithInteger:[eidString integerValue]];
        
        NSArray *messagesJSON = obj;
        NSMutableArray *messagesForEid = [[NSMutableArray alloc] initWithCapacity:[messagesJSON count]];
        
        for (int i = 0; i < [messagesJSON count]; ++i){
            NSDictionary *messageJSON = [messagesJSON objectAtIndex:i];
            FZZMessage *message = [FZZMessage parseJSON:messageJSON];
            [messagesForEid addObject:message];
        }
        
        [result setObject:messagesForEid forKey:eid];
    }];
    
    return result;
}

- (NSDictionary *)jsonDict{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:self.messageID forKey:@"mid"];
    [dict setObject:self.event.eventID forKey:@"eid"];
    [dict setObject:self.user.userID forKey:@"uid"];
    
    NSNumber *creationTime = [NSNumber numberWithInt:[self.creationTime timeIntervalSince1970]];
    
    [dict setObject:creationTime forKey:@"creationTime"];
    
    if (self.text){
        [dict setObject:self.text forKey:@"text"];
    }
    
    if (self.marker){
        [dict setObject:[self.marker jsonDict] forKey:@"marker"];
    }
    
    return dict;
}

// Returns true if message is from Fizz, not from a user
-(BOOL)isServerMessage{
    return (self.user == NULL);
}

@end

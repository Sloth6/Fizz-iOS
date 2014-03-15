//
//  BCNMessage.m
//  Beacon
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import "BCNMessage.h"
#import "BCNEvent.h"
#import "BCNUser.h"
#import "BCNMarker.h"

static NSString *BCN_NEW_MESSAGE = @"newMessage";

@interface BCNMessage ()

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) BCNUser  *user;
@property (strong, nonatomic) BCNEvent *event;
@property (strong, nonatomic) NSNumber *messageID;
@property (strong, nonatomic) BCNMarker *marker;
@property (strong, nonatomic) NSDate *creationTime;

@end

@implementation BCNMessage

@synthesize user, text, event, messageID;

-(id)initWithMID:(NSNumber *)mID User:(BCNUser *)inputUser AndText:(NSString *)inputText ForEvent:(BCNEvent *)inputEvent{
    self = [super init];
    
    if (self){
        self.messageID = mID;
        self.user = inputUser;
        self.text = inputText;
        self.event = inputEvent;
    }
    
    return self;
}

-(BCNUser *)user{
    return user;
}

-(NSString *)text{
    return text;
}

+(void)socketIONewMessage:(BCNMessage *)message
                 ForEvent:(BCNEvent *)event
          WithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    /* eid : int */
    [json setObject:[event eventID] forKey:@"eid"];
    
    /* message : message */
    NSDictionary *messageJSON = [message jsonDict];
    
    [json setObject:messageJSON forKey:@"message"];
    
    BCN_IOSocketDelegate *socketIODelegate = [BCNObject getIOSocketDelegate];
    
    [[socketIODelegate socketIO] sendEvent:BCN_NEW_MESSAGE withData:json andAcknowledge:function];
}

+(BCNMessage *)parseJSON:(NSDictionary *)messageJSON{
    if (messageJSON == NULL){
        return NULL;
    }
    
    // Message ID
    NSNumber *mid = [messageJSON objectForKey:@"mid"];
    
    // Event ID (Event this message belongs to)
    BCNEvent *event;
    {
        NSNumber *eid = [messageJSON objectForKey:@"eid"];
        event = [BCNEvent eventWithEID:eid];
    }
    
    // User ID of the message poster
    BCNUser *user;
    {
        NSNumber *uid = [messageJSON objectForKey:@"uid"];
        user = [BCNUser userWithUID:uid];
    }
    
    // Text of the message sent
    NSString *text = [messageJSON objectForKey:@"text"];
    
    // When this message was created
    NSDate *creationTime;
    {
        NSNumber *creationTimeNum = [messageJSON objectForKey:@"creationTime"];
        creationTime = [NSDate dateWithTimeIntervalSince1970:[creationTimeNum integerValue]];
    }
    
    BCNMessage *message = [[BCNMessage alloc] initWithMID:mid
                                                     User:user
                                                  AndText:text
                                                 ForEvent:event];
    
    message.creationTime = creationTime;
    
    /* Optional Marker can be attached to a message to put it on the map */
    NSDictionary *markerJSON = [messageJSON objectForKey:@"marker"];
    
    if (markerJSON){
        BCNMarker *marker = [BCNMarker parseJSON:markerJSON];
        message.marker = marker;
    }
    
    //[messageJSON objectForKey:@"deletePastMarker"];
    
    return message;
}

- (NSDictionary *)jsonDict{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:self.messageID forKey:@"mid"];
    [dict setObject:self.event.eventID forKey:@"eid"];
    [dict setObject:self.user.userID forKey:@"uid"];
    [dict setObject:self.text forKey:@"text"];
    
    NSNumber *creationTime = [NSNumber numberWithInt:[self.creationTime timeIntervalSince1970]];
    
    [dict setObject:creationTime forKey:@"creationTime"];
    
    if (self.marker){
        [dict setObject:[self.marker jsonDict] forKey:@"marker"];
    }
    
    return dict;
}

-(NSDate *)timestamp{
    return self.creationTime;
}

@end

//
//  FZZMessage.h
//  Fizz
//
//  Created by Andrew Sweet on 5/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

/*
 
 Unlike FZZEvent's and FZZUser's, FZZMessage's are not stored within the FZZMessage class, and should instead be maintained as an array of messages externally. This is due to the fact that while a FZZUser is found in multiple events, a FZZMessage will only ever be found in one event.
 
 Send messages from this class with the [SocketIONewMessage:... ForEvent:... WithAcknowledge:...] call
 
 WithAcknowledge should generally accept a null object. Whatever SocketIOCallback function is passed to that parameter will be called when the socket object is successfully sent. It may actually be when a callback from the server occurs; I believe it to be the first, and so I don't think it's nearly as useful.
 
 */

@class FZZCoordinate, FZZEvent, FZZUser;

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SocketIO.h"

@interface FZZMessage : NSManagedObject

@property (nonatomic, retain) NSDate * creationTime;
@property (nonatomic, retain) NSNumber * messageID;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) FZZEvent *event;
@property (nonatomic, retain) FZZCoordinate *marker;
@property (nonatomic, retain) FZZUser *user;

-(BOOL)isServerMessage;

-(id)initWithMID:(NSNumber *)mID User:(FZZUser *)inputUser AndText:(NSString *)inputText ForEvent:(FZZEvent *)inputEvent;

+(void)socketIONewMessage:(NSString *)message
                 ForEvent:(FZZEvent *)event
          WithAcknowledge:(SocketIOCallback)function;

+(FZZMessage *)parseJSON:(NSDictionary *)messageJSON;
+(NSDictionary *)parseMessageJSONDict:(NSDictionary *)messageDictJSON;

@end

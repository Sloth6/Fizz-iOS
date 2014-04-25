//
//  FZZMessage.h
//  Fizz
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

@class FZZEvent;
@class FZZUser;

#import "SocketIO.h"

@interface FZZMessage : NSObject

-(FZZEvent *)event;
-(FZZUser *)user;
-(NSString *)text;
-(NSDate *)timestamp;
-(NSNumber *)messageID;

-(BOOL)isServerMessage;

-(id)initWithMID:(NSNumber *)mID User:(FZZUser *)inputUser AndText:(NSString *)inputText ForEvent:(FZZEvent *)inputEvent;

+(void)socketIONewMessage:(NSString *)message
                 ForEvent:(FZZEvent *)event
          WithAcknowledge:(SocketIOCallback)function;

+(FZZMessage *)parseJSON:(NSDictionary *)messageJSON;

@end

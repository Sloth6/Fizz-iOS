//
//  BCNMessage.h
//  Beacon
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

@class BCNEvent;
@class BCNUser;

#import "SocketIO.h"

@interface BCNMessage : NSObject

-(BCNUser *)user;
-(NSString *)text;
-(NSDate *)timestamp;

-(id)initWithMID:(NSNumber *)mID User:(BCNUser *)inputUser AndText:(NSString *)inputText ForEvent:(BCNEvent *)inputEvent;

+(void)socketIONewMessage:(NSString *)message
                 ForEvent:(BCNEvent *)event
          WithAcknowledge:(SocketIOCallback)function;

+(BCNMessage *)parseJSON:(NSDictionary *)messageJSON;

@end

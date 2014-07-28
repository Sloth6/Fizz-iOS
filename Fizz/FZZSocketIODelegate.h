//
//  FZZSocketIODelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//


/*
 
 The FZZSocketIODelegate handles all socket connections with the Fizz servers. This is where incoming messages from the server are handled. All outgoing messages are handled within the object that corresponds with the action (ie if you send a message, the server call would be made from the FZZMessage class. Some calls are static calls from the class itself, while others are made from an instance of the object).
 
 */

#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "SocketIOPacket.h"

/* Server Info */
static NSString * const kFZZSocketHost = @"localhost";//@"68.225.244.171";//@"54.84.205.222";//@"128.237.139.204";//@"localhost"
static int const kFZZSocketPort = 9001;

static int const kFZZDefaultReconnectDelay = 5; // 5 seconds
static int const kFZZMaximumReconnectDelay = 300; // 5 minutes


@interface FZZSocketIODelegate : NSObject <SocketIODelegate, NSURLConnectionDelegate>

+ (void)initialize;

// Perform the ajax post for login
+ (void) openConnectionCheckingForInternet;

+ (void) willResignActive;
//+ (void) logout;
+ (BOOL) isConnectionOpen;
+ (SocketIO *)socketIO;
+(void)socketIOResetDataFromServerWithAcknowledge:(SocketIOCallback)function;

+(FZZSocketIODelegate *)socketIODelegate;

@end

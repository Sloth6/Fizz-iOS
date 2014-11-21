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

// Incoming Server Communication
extern NSString * const FZZ_INCOMING_ON_LOGIN;
extern NSString * const FZZ_INCOMING_NEW_EVENT;
extern NSString * const FZZ_INCOMING_COMPLETE_EVENT;
extern NSString * const FZZ_INCOMING_UPDATE_GUESTS;
extern NSString * const FZZ_INCOMING_NEW_INVITEES;
extern NSString * const FZZ_INCOMING_NEW_MESSAGE;
extern NSString * const FZZ_INCOMING_UPDATE_EVENT;

/* Server Info */
static NSString * const kFZZSocketHost = @"54.69.196.168";//@"ec2-54-173-45-6.compute-1.amazonaws.com";//@"68.225.244.171";//@"54.84.205.222";//@"128.237.139.204";//@"localhost"
static int const kFZZSocketPort = 9001;

static int const kFZZDefaultReconnectDelay = 2; // 5 seconds
static int const kFZZMaximumReconnectDelay = 120; // 2 minutes


@interface FZZSocketIODelegate : NSObject <SocketIODelegate, NSURLConnectionDelegate>

+ (void)initialize;

// Perform the ajax post for login
+ (void) openConnectionCheckingForInternet;

+ (void) willResignActive;
//+ (void) logout;
+ (BOOL) isConnectionOpen;
+ (SocketIO *)socketIO;

+(FZZSocketIODelegate *)socketIODelegate;

+(BOOL)recentLogin;

@end

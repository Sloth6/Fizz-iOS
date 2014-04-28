//
//  FZZSocketIODelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "SocketIOPacket.h"

/* Server Info */
static NSString * const kFZZSocketHost = @"54.84.205.222";//@"128.237.139.204";//@"localhost";//
static int const kFZZSocketPort = 9001;

static int const kFZZDefaultReconnectDelay = 5; // 5 seconds
static int const kFZZMaximumReconnectDelay = 300; // 5 minutes


@interface FZZSocketIODelegate : NSObject <SocketIODelegate, NSURLConnectionDelegate>

+ (void) openConnectionCheckingForInternet;
+ (void) willResignActive;
//+ (void) logout;
+ (BOOL) isConnectionOpen;
+ (SocketIO *)socketIO;

@end

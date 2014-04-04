//
//  BCN_IOSocketDelegate.h
//  Beacon
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketIO.h"
#import "SocketIOPacket.h"

/* Server Info */
static NSString * const kBCNSocketHost = @"localhost";//@"128.237.214.9";//@"54.85.14.197";//@"localhost";//@"128.237.214.9";//
static int const kBCNSocketPort = 9001;

static int const kBCNDefaultReconnectDelay = 5; // 5 seconds
static int const kBCNMaximumReconnectDelay = 300; // 5 minutes


@interface BCN_IOSocketDelegate : NSObject <SocketIODelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) SocketIO *socketIO;

- (void) openConnectionCheckingForInternet;
- (void) willResignActive;
- (void) logout;
- (BOOL) isConnectionOpen;

@end

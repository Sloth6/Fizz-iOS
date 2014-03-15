//
//  BCN_IOSocketDelegate.m
//  Beacon
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import "BCN_IOSocketDelegate.h"
#import "BCN_Reachability.h"
#import "SBJson4.h"
#import "BCNEvent.h"
#import "BCNUser.h"
#import "BCNMessage.h"
#import "BCNFriendList.h"
#import "BCNAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

static NSString *BCN_INCOMING_MY_INFO = @"myInfo";
static NSString *BCN_INCOMING_FRIEND_LIST = @"friendList";
static NSString *BCN_INCOMING_EVENT_LIST = @"eventList";
static NSString *BCN_INCOMING_NEW_EVENT = @"newEvent";
static NSString *BCN_INCOMING_ADD_GUEST = @"addGuest";
static NSString *BCN_INCOMING_REMOVE_GUEST = @"removeGuest";
static NSString *BCN_INCOMING_NEW_MESSAGE = @"newMessage";
static NSString *BCN_INCOMING_NEW_USER_LOCATION_LIST = @"newUserLocationList";

@interface BCN_IOSocketDelegate ()

@property NSDictionary *incomingEventResponses;

@property int reconnectDelay;
@property BOOL connected;
@property BOOL resignedActive;
//@property (strong, nonatomic) NSString *beaconSessionToken;
@property BOOL didAjax;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *data;

@end

@implementation BCN_IOSocketDelegate

@synthesize socketIO, reconnectDelay, connected, incomingEventResponses,
            didAjax, connection, data, resignedActive;

-(id) init{
    self = [super init];
    
    if (self){
        reconnectDelay = kBCNDefaultReconnectDelay;
        socketIO = [[SocketIO alloc] initWithDelegate:self];
        connected = NO;
        didAjax = NO;
        resignedActive = NO;
        
        incomingEventResponses = [[NSMutableDictionary alloc] init];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingMyInfo:))
                                  forKey:BCN_INCOMING_MY_INFO];
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingFriendList:))
                                  forKey:BCN_INCOMING_FRIEND_LIST];
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingEventList:))
                                  forKey:BCN_INCOMING_EVENT_LIST];
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewEvent:))
                                  forKey:BCN_INCOMING_NEW_EVENT];
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingAddGuest:))
                                  forKey:BCN_INCOMING_ADD_GUEST];
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingRemoveGuest:))
                                  forKey:BCN_INCOMING_REMOVE_GUEST];
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewMessage:))
                                  forKey:BCN_INCOMING_MY_INFO];
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewUserLocationList:))
                                  forKey:BCN_INCOMING_NEW_USER_LOCATION_LIST];
    }
    
    return self;
}

/* Check for a network connection. Attempt to connect to network with increasing time intervals. */
- (void) openConnectionCheckingForInternet{
    BCN_Reachability *reachability = [BCN_Reachability reachabilityForInternetConnection];
    
    if ([reachability isReachable]){
        [self openConnection];
    } else {
        [self performSelector:@selector(openConnectionCheckingForInternet) withObject:nil afterDelay:reconnectDelay];
        
        [self updateReconnectDelay];
    }
}

/* AJAX */

- (BOOL)ajaxGetRequest{
    NSLog(@"getting FBaccessToken");
    
    NSString *accessToken = [FBSession activeSession].accessTokenData.accessToken;
    
    if (accessToken){
        NSLog(@"sending AJAX");
        
        NSArray *keys = [NSArray arrayWithObjects:@"access_token", nil];
        NSArray *objects = [NSArray arrayWithObjects:accessToken, nil];
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

        SBJson4Writer *writer = [[SBJson4Writer alloc] init];
        
        NSString *jsonString = [writer stringWithObject:jsonDictionary];
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/iosLogin", kBCNSocketHost, kBCNSocketPort]]];
        [request setValue:jsonString forHTTPHeaderField:@"json"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        
        connection = [[NSURLConnection alloc]
                      initWithRequest:request
                      delegate:self
                      startImmediately:NO];
        
        /*[connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                              forMode:NSDefaultRunLoopMode];*/
        
        [connection start];
        didAjax = YES;
        
        return YES;
    }
    
    return NO;
}

- (void)logout{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"http://%@:%d/logout", kBCNSocketHost, kBCNSocketPort];
    
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return;
    }
    
    didAjax = NO;
    NSLog(@"Logged out");
    
    
    NSLog(@"%@",[[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding]);
}

- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten
{
    NSLog(@"didwriteData push");
}
- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    NSLog(@"connectionDidResumeDownloading push");
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    NSLog(@"didfinish push @push %@",data);
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSLog(@"did send body");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.data setLength:0];
    NSHTTPURLResponse *resp= (NSHTTPURLResponse *) response;
    NSLog(@"got response with status @push %d",[resp statusCode]);
    
    if ([resp statusCode] == 200){
        [self openConnectionCheckingForInternet];
    } else {
        // AJAX failed
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    [self.data appendData:d];
    
    NSLog(@"recieved data @push %@", data);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseText = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
    
    NSLog(@"didfinishLoading%@",responseText);
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error ", @"")
                                message:[error localizedDescription]
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                      otherButtonTitles:nil] show];
    NSLog(@"failed &push");
}

// Handle basic authentication challenge if needed
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"credentials requested");
    NSString *username = @"username";
    NSString *password = @"password";
    
    NSURLCredential *credential = [NSURLCredential credentialWithUser:username
                                                             password:password
                                                          persistence:NSURLCredentialPersistenceForSession];
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}


- (void) openConnection{
    resignedActive = NO;
    
    if (didAjax){
        [socketIO connectToHost:kBCNSocketHost onPort:kBCNSocketPort];
    } else {
        [self ajaxGetRequest];
    }
}

/* Connect */

- (void) socketIODidConnect:(SocketIO *)socket{
    connected = YES;
    NSLog(@"\n[socketIO] Connection Opened\n");
    reconnectDelay = kBCNDefaultReconnectDelay;
}

/* Disconnect */

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error{
    connected = NO;
    NSLog(@"\n[socketIO] Connection Disconnected\n");
    if (!resignedActive){ NSLog(@"\n[socketIO] Attempting to Reconnect\n");
        [self performSelector:@selector(reconnect) withObject:nil afterDelay:reconnectDelay];
    }
}

- (void) updateReconnectDelay{
    // Ramp up how often you try to reconnect from every 5 seconds to every 5 minutes
    if (reconnectDelay < kBCNMaximumReconnectDelay){
        reconnectDelay += ((reconnectDelay / 20) + 1) * 5;
        
        reconnectDelay = MIN(reconnectDelay, kBCNMaximumReconnectDelay);
    }
}

- (void) reconnect{
    [socketIO disconnect];
    [self openConnectionCheckingForInternet];
    NSLog(@"OPENCONN 2");
}

- (void) willResignActive{
    resignedActive = YES;
    
    if (connected){
        [socketIO disconnect];
        connected = NO;
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        reconnectDelay = kBCNDefaultReconnectDelay;
    }
}

/* Recieve */

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet{
    NSLog(@"Message recieved: %@", packet.data);
}

// All messages recieved should be events
- (void) socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet{
    NSLog(@"JSON recieved: %@", packet.data);
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet{
    NSLog(@"Event recieved: %@", packet.data);
    
    NSDictionary *event = packet.dataAsJSON;
    
    NSString *eventName = [event objectForKey:@"name"];
    
    NSString *functionName = [incomingEventResponses objectForKey:eventName];
    
    if (functionName != nil){
        NSArray *args = [event objectForKey:@"args"];
        
        SEL function = NSSelectorFromString(functionName);
        
        SuppressPerformSelectorLeakWarning(
            [self performSelectorInBackground:function withObject:args];
        );
    }
}

- (void)incomingMyInfo:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSDictionary *userJSON = [json objectForKey:@"me"];
    
    BCNUser *user = [BCNUser parseJSON:userJSON];
}

- (void)incomingFriendList:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSDictionary *friendListJSON = [json objectForKey:@"friendList"];
    
    BCNFriendList *friendList = [BCNFriendList parseJSON:friendListJSON];
}

- (void)incomingEventList:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSArray *eventListJSON = [json objectForKey:@"eventList"];
    
    NSArray *events = [BCNEvent parseEventJSONList:eventListJSON];
    
    BCNAppDelegate *appDelegate = (BCNAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate updateEvents:events];
}

- (void)incomingNewEvent:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSDictionary *eventJSON = [json objectForKey:@"event"];
    
    BCNEvent *event = [BCNEvent parseJSON:eventJSON];
}

- (void)incomingAddGuest:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSNumber *eventID = [json objectForKey:@"eid"];
    NSNumber *userID  = [json objectForKey:@"uid"];
    
    BCNEvent *event = [BCNEvent eventWithEID:eventID];
    BCNUser  *user  = [BCNUser userWithUID:userID];
}

- (void)incomingRemoveGuest:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSNumber *eventID = [json objectForKey:@"eid"];
    NSNumber *userID  = [json objectForKey:@"uid"];
    
    BCNEvent *event = [BCNEvent eventWithEID:eventID];
    BCNUser  *user  = [BCNUser userWithUID:userID];
}

- (void)incomingNewMessage:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSDictionary *messageJSON = [json objectForKey:@"message"];
    
    BCNMessage *message = [BCNMessage parseJSON:messageJSON];
}

- (void)incomingNewUserLocationList:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSDictionary *userLocationJSON = [json objectForKey:@"userLocation"];
    
    NSNumber *uid = [userLocationJSON objectForKey:@"uid"];
    
    BCNUser *user = [BCNUser userWithUID:uid];
    
    NSDictionary *latlngJSON = [userLocationJSON objectForKey:@"latlng"];
    
    BCNCoordinate *coord = [BCNCoordinate parseJSON:latlngJSON];
}


-(void)incomingLoginSuccess:(NSArray *)args{
    NSDictionary *json = [args objectAtIndex:0];
    NSNumber *isAdmin = [json objectForKey:@"admin"];
    
}

/* Send */

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet{
    
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error{
    NSLog(@"\n[socketIO] Error: %@\n", error);
}

- (BOOL) isConnectionOpen{
    return connected;
}


@end
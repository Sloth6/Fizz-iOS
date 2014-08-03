//
//  FZZ_IOSocketDelegate.m
//  Fizz
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import "FZZSocketIODelegate.h"
#import "FZZAjaxPostDelegate.h"
#import "FZZ_Reachability.h"
#import "SBJson4.h"
#import "FZZEvent.h"
#import "FZZUser.h"
#import "FZZMessage.h"
#import "FZZAppDelegate.h"
#import "FZZInviteViewController.h"
#import "FZZLocationManager.h"

#import "FZZLocalCache.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

// Incoming Server Communication
static NSString *FZZ_INCOMING_ON_LOGIN = @"onLogin";
static NSString *FZZ_INCOMING_NEW_EVENT = @"newEvent";
static NSString *FZZ_INCOMING_COMPLETE_EVENT = @"completeEvent";
static NSString *FZZ_INCOMING_UPDATE_GUESTS = @"updateGuests";
static NSString *FZZ_INCOMING_UPDATE_INVITEES = @"updateInvitees";
static NSString *FZZ_INCOMING_NEW_MESSAGE = @"newMessage";
static NSString *FZZ_INCOMING_UPDATE_EVENT = @"updateEvent";


// Outgoing Server Communication
static NSString *FZZ_RESET = @"reset";

static BOOL hasMadeDelegate = NO;
static FZZSocketIODelegate *socketIODelegate;

static SocketIO *socketIO;

static NSDictionary *incomingEventResponses;

static int reconnectDelay;
static BOOL connected;
static BOOL resignedActive;
static NSMutableData *data;

@interface FZZSocketIODelegate ()

@end

@implementation FZZSocketIODelegate

+(FZZSocketIODelegate *)socketIODelegate{
    return socketIODelegate;
}

+ (void)initialize{
    if (self == [FZZSocketIODelegate class])
    {
        // Once-only initializion
        socketIODelegate = [[FZZSocketIODelegate alloc] init];
        hasMadeDelegate = YES;
        
        reconnectDelay = kFZZDefaultReconnectDelay;
        socketIO = [[SocketIO alloc] initWithDelegate:socketIODelegate];
        connected = NO;
        resignedActive = NO;
        
        incomingEventResponses = [[NSMutableDictionary alloc] init];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingOnLogin:))
                                  forKey:FZZ_INCOMING_ON_LOGIN];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewEvent:))
                                  forKey:FZZ_INCOMING_NEW_EVENT];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingCompleteEvent:))
                                  forKey:FZZ_INCOMING_COMPLETE_EVENT];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingUpdateGuests:))
                                  forKey:FZZ_INCOMING_UPDATE_GUESTS];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingUpdateInvitees:))
                                  forKey:FZZ_INCOMING_UPDATE_INVITEES];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewMessage:))
                                  forKey:FZZ_INCOMING_NEW_MESSAGE];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingUpdateEvent:))
                                  forKey:FZZ_INCOMING_UPDATE_EVENT];
        
        
        
        // Initialization for this class and any subclasses
    }
}

// Generally does not allow FZZSocketIODelegate to exist outside of the class
-(id) init{
    if (hasMadeDelegate){
        return NULL;
    }
    
    self = [super init];
    
    if (self){
        
    }
    
    return self;
}

/* Check for a network connection. Attempt to connect to network with increasing time intervals. */
+ (void) openConnectionCheckingForInternet{
    if ([self isConnectionOpen]) return;
    
    FZZ_Reachability *reachability = [FZZ_Reachability reachabilityForInternetConnection];
    
    if ([reachability isReachable]){
        NSLog(@"isReachable");
        
        [FZZAjaxPostDelegate postLogin];
        
    } else {
        NSLog(@"is NOT reachable");
        
        [self performSelector:@selector(openConnectionCheckingForInternet) withObject:nil afterDelay:reconnectDelay];
        
        [socketIODelegate updateReconnectDelay];
    }
}

+ (SocketIO *)socketIO{
    return socketIO;
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
    [data setLength:0];
    
    if ([FZZAjaxPostDelegate connection:connection didRecieveResponse:response]){
        [[FZZSocketIODelegate socketIODelegate] openConnection];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d
{
    [data appendData:d];
    
    NSLog(@"recieved data @push %@", data);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
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


- (void)openConnection{
    resignedActive = NO;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSNumber *didRegister = [pref objectForKey:@"didRegister"];
    
    if ([didRegister boolValue]){
        NSLog(@"userDidRegister in the past");
        
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        // pass cookie(s) to handshake endpoint (e.g. for auth)
        [FZZSocketIODelegate socketIO].cookies = [cookieJar cookies];
        
        NSLog(@"\n\nCOOKIES: <%@>\n\n", [FZZSocketIODelegate socketIO].cookies);
        
        [[FZZSocketIODelegate socketIO] connectToHost:kFZZSocketHost onPort:kFZZSocketPort];
        
        [FZZLocationManager initialize];
        
//        } else {
//            // Send user to the registration screen again
//            FZZAppDelegate *delegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//            
//            // TODOAndrew implement the app forcing you to jump to registration
//            //[delegate forceUserRegistration];
//        }
        return;
    }
    
    NSLog(@"Cannot open connection without having registered");
    exit(1);
}

/* Connect */

- (void) socketIODidConnect:(SocketIO *)socket{
    connected = YES;
    NSLog(@"\n[socketIO] Connection Opened\n");
    reconnectDelay = kFZZDefaultReconnectDelay;
}

/* Disconnect */

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error{
    connected = NO;
    NSLog(@"\n[socketIO] Connection Disconnected\n");
    if (!resignedActive){ NSLog(@"\n[socketIO] Attempting to Reconnect\n");
        [socketIODelegate performSelector:@selector(reconnect) withObject:nil afterDelay:reconnectDelay];
    }
}

- (void) updateReconnectDelay{
    // Ramp up how often you try to reconnect from every 5 seconds to every 5 minutes
    if (reconnectDelay < kFZZMaximumReconnectDelay){
        reconnectDelay += ((reconnectDelay / 20) + 1) * 5;
        
        reconnectDelay = MIN(reconnectDelay, kFZZMaximumReconnectDelay);
    }
}

- (void) reconnect{
    [[FZZSocketIODelegate socketIO] disconnect];
    [FZZSocketIODelegate openConnectionCheckingForInternet];
    NSLog(@"OPENCONN 2");
}

+ (void) willResignActive{
    resignedActive = YES;
    
    if (connected){
        [[FZZSocketIODelegate socketIO] disconnect];
        connected = NO;
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:socketIODelegate];
        reconnectDelay = kFZZDefaultReconnectDelay;
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
            [socketIODelegate performSelectorInBackground:function withObject:args];
        );
    }
}

- (void)incomingOnLogin:(NSArray *)args{
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isConnecting = NO;
    
    NSLog(@"\nONLOGIN INCOMING: %@\n", args);
    
    NSDictionary *json  = [args objectAtIndex:0];
    
    // User (me)
    NSDictionary *userJSON   = [json objectForKey:@"me"];
    
    FZZUser *me = [FZZUser parseJSON:userJSON];
    
    [FZZUser setMeAs:me];

    if (![FZZLocalCache hasLoadedDataFromCache]){
        // Load all cached data if user data is cached
        [FZZLocalCache loadFromCache];
    }
    
    NSArray *eventIDList = [json objectForKey:@"eventList"];
    NSArray *completeEventIDList = [json objectForKey:@"completeEventList"];
    NSDictionary *messageDictJSON = [json objectForKey:@"newMessages"];
    
    // User array (additive)
    NSDictionary *invitees = [json objectForKey:@"newInvitees"];
    
    // uid arrays (absolute)
    NSDictionary *guests   = [json objectForKey:@"guests"];
    
    // Events
    NSArray *newEvents = [FZZEvent parseEventIDList:eventIDList];
    
    // complete Events
    [FZZEvent killEvents:completeEventIDList];
    
    // After killing events, append new ones, update interface
    [appDelegate updateEvents:newEvents];
    
    // Messages
    // Parses the JSON, places messages in the appropriate events
    NSDictionary *messageCounts = [FZZMessage parseMessageJSONDict:messageDictJSON];
    
    /* Handle invitees before guests  */
    // newInvitees
    
    [invitees enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *eventID = [NSNumber numberWithInt:[(NSString *)key intValue]];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        NSArray *updatedInvitees = (NSArray *)obj;
        
        [event updateAddInvitees:updatedInvitees];
    }];
    
    // guests
    [guests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *eventID = [NSNumber numberWithInt:[(NSString *)key intValue]];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        NSArray *updatedGuests = [FZZUser parseUserJSONList:(NSArray *)obj];
        
        [event updateGuests:updatedGuests];
    }];
    
    // TODOAndrew Update visual elements!
    
    // After all users are loaded in, update available friends to invite
    // TODOAndrew Check out what update friends is doing, cache the friendslist?
    [FZZInviteViewController updateFriends];
}

- (void)incomingNewEvent:(NSArray *)args{
    NSLog(@"\n\nINCOMING EVENT: %@\n", args);
    
    NSDictionary *json  = [args objectAtIndex:0];
    
    FZZEvent *event = [FZZEvent parseJSON:json];
    
    NSArray *newEvents = [NSArray arrayWithObject:event];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateEvents:newEvents];
}

- (void)incomingCompleteEvent:(NSArray *)args{
    NSDictionary *json = [args objectAtIndex:0];
    
    NSNumber *eID = [json objectForKey:@"eid"];
    
    [FZZEvent killEvents:[NSArray arrayWithObject:eID]];

    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
    // TODOAndrew get rid of this hack to relead events, have killEvents actually update the eventsList visually
    [appDelegate updateEvents:[[NSArray alloc] init]];
}

- (void)incomingUpdateGuests:(NSArray *)args{
    NSDictionary *json = [args objectAtIndex:0];
    
    NSNumber *eID = [json objectForKey:@"eid"];
    FZZEvent *event = [FZZEvent eventWithEID:eID];
    
    NSArray *guests = [json objectForKey:@"guests"];
    
    [event updateGuests:guests];
}

- (void)incomingUpdateInvitees:(NSArray *)args{
    NSDictionary *json = [args objectAtIndex:0];
    
    NSNumber *eventID = [json objectForKey:@"eid"];
    FZZEvent *event = [FZZEvent eventWithEID:eventID];
    
    NSArray *invitees = [json objectForKey:@"invitees"];
    
    [event updateAddInvitees:invitees];
}

- (void)incomingNewMessage:(NSArray *)args{
    
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSLog(@"NEW MESSAGE: %@", json);
    
    NSDictionary *messageDict = [json objectForKey:@"message"];
    
    FZZMessage *message = [FZZMessage parseJSON:messageDict];
    
    FZZEvent *event = [message event];
    
    [event updateAddMessage:message];

    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;

    FZZEventsViewController *evc = [appDelegate evc];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [evc addIncomingMessageForEvent:event];
    });
}

- (void)incomingUpdateEvent:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSNumber *eid = [json objectForKey:@"eid"];
    
    NSString *eventDescription = [json objectForKey:@"description"];
    
    FZZEvent *event = [FZZEvent eventWithEID:eid];
    
    // Update visually too
    [event updateEventDescription:eventDescription];
}

//- (void)incomingNewUserLocationList:(NSArray *)args{
//    NSDictionary *json  = [args objectAtIndex:0];
//    
//    NSDictionary *userLocationJSON = [json objectForKey:@"userLocation"];
//    
//    NSNumber *uid = [userLocationJSON objectForKey:@"uid"];
//    
//    FZZUser *user = [FZZUser userWithUID:uid];
//    
//    NSDictionary *latlngJSON = [userLocationJSON objectForKey:@"latlng"];
//    
//    FZZCoordinate *coord = [FZZCoordinate parseJSON:latlngJSON];
//}


/* Send */

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet{
    
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error{
    NSLog(@"\n[socketIO] Error: %@\n", error);
}

+ (BOOL) isConnectionOpen{
    return connected;
}

+(void)socketIOResetDataFromServerWithAcknowledge:(SocketIOCallback)function{
    NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
    
    [[FZZSocketIODelegate socketIO] sendEvent:FZZ_RESET withData:json andAcknowledge:function];
}


@end

//
//  FZZ_IOSocketDelegate.m
//  Fizz
//
//  Created by Andrew Sweet on 12/20/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import "FZZSocketIODelegate.h"
#import "FZZ_Reachability.h"
#import "SBJson4.h"
#import "FZZEvent.h"
#import "FZZUser.h"
#import "FZZMessage.h"
#import "FZZAppDelegate.h"
#import "FZZInviteViewController.h"
#import <FacebookSDK/FacebookSDK.h>

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
static NSString *FZZ_INCOMING_COMPLETED_EVENT = @"completedEvent";
static NSString *FZZ_INCOMING_UPDATE_GUESTS = @"updateGuests";
static NSString *FZZ_INCOMING_UPDATE_INVITEES = @"updateInvitees";
static NSString *FZZ_INCOMING_NEW_MESSAGE = @"newMessage";
static NSString *FZZ_INCOMING_UPDATE_CLUSTERS = @"updateClusters";
static NSString *FZZ_INCOMING_UPDATE_LOCATION = @"updateLocation";
static NSString *FZZ_INCOMING_UPDATE_TIME = @"updateTime";
static NSString *FZZ_INCOMING_UPDATE_EVENT = @"updateEvent";


// Outgoing Server Communication
static NSString *FZZ_RESET = @"reset";

static BOOL hasMadeDelegate = NO;
static FZZSocketIODelegate *delegate;

static SocketIO *socketIO;

static NSDictionary *incomingEventResponses;

static int reconnectDelay;
static BOOL connected;
static BOOL resignedActive;
static BOOL didAjax;
static NSURLConnection *connection;
static NSMutableData *data;

@interface FZZSocketIODelegate ()

@end

@implementation FZZSocketIODelegate

+ (void)initialize{
    // Once-only initializion
    delegate = [[FZZSocketIODelegate alloc] init];
    hasMadeDelegate = YES;
    
    reconnectDelay = kFZZDefaultReconnectDelay;
    socketIO = [[SocketIO alloc] initWithDelegate:delegate];
    connected = NO;
    didAjax = NO;
    resignedActive = NO;
    
    incomingEventResponses = [[NSMutableDictionary alloc] init];
    
    [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingOnLogin:))
                              forKey:FZZ_INCOMING_ON_LOGIN];
    
    [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewEvent:))
                              forKey:FZZ_INCOMING_NEW_EVENT];
    
    [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingCompletedEvent:))
                              forKey:FZZ_INCOMING_COMPLETED_EVENT];
    
    [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingUpdateGuests:))
                              forKey:FZZ_INCOMING_UPDATE_GUESTS];
    
    [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingUpdateInvitees:))
                              forKey:FZZ_INCOMING_UPDATE_INVITEES];
    
    [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewMessage:))
                              forKey:FZZ_INCOMING_NEW_MESSAGE];
    
    [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingUpdateClusters:))
                              forKey:FZZ_INCOMING_UPDATE_CLUSTERS];
    
    [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingUpdateLocation:))
                              forKey:FZZ_INCOMING_UPDATE_LOCATION];
    
    [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingUpdateTime:))
                              forKey:FZZ_INCOMING_UPDATE_TIME];
    
    [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingUpdateEvent:))
                              forKey:FZZ_INCOMING_UPDATE_EVENT];
    
    
    
    // Initialization for this class and any subclasses
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
    FZZ_Reachability *reachability = [FZZ_Reachability reachabilityForInternetConnection];
    
    if ([reachability isReachable]){
        NSLog(@"isReachable");
        
        [delegate openConnection];
    } else {
        NSLog(@"is NOT reachable");
        
        [self performSelector:@selector(openConnectionCheckingForInternet) withObject:nil afterDelay:reconnectDelay];
        
        [delegate updateReconnectDelay];
    }
}

/* AJAX */

- (BOOL)ajaxPostRequest{
    NSLog(@"AJAX REQUEST");
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.isConnecting = YES;
    
    NSString *fbToken = [FBSession activeSession].accessTokenData.accessToken;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *iosToken = [pref objectForKey:@"iosToken"];
    
    NSString *phoneNumber = [pref objectForKey:@"phoneNumber"];
    
    if (fbToken){
        
        NSLog(@"sending AJAX");
        
        // FB Session Token
        // TODOAndrew Remove all fbToken
        NSMutableArray *keys = [[NSMutableArray alloc] initWithObjects:@"fbToken", nil];
        NSMutableArray *objects = [[NSMutableArray alloc] initWithObjects:fbToken, nil];
        
        NSLog(@"fbToken: %@", fbToken);
        
        // Phone Number
        if (phoneNumber != NULL){
            [keys addObject:@"pn"];
            [objects addObject:phoneNumber];
            
            NSLog(@"pn: %@", phoneNumber);
        }
        
        // iOS Token
        if (iosToken != NULL){
            [keys addObject:@"iosToken"];
            [objects addObject:iosToken];
            
            NSLog(@"iosToken: %@", iosToken);
        }
        
        // Version Number
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [info objectForKey:@"CFBundleShortVersionString"];
        
        [keys addObject:@"appVersion"];
        [objects addObject:version];
        
        NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

        SBJson4Writer *writer = [[SBJson4Writer alloc] init];
        
        NSString *jsonString = [writer stringWithObject:jsonDictionary];
        
        NSLog(@"\n\n%@\n\n", jsonString);
        
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%d/login", kFZZSocketHost, kFZZSocketPort]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonData];
        
        connection = [[NSURLConnection alloc]
                      initWithRequest:request
                      delegate:delegate
                      startImmediately:NO];
        
        /*[connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                              forMode:NSDefaultRunLoopMode];*/
        
        [connection start];
        appDelegate.hasLoggedIn = YES;
        
        return YES;
    }
    
    return NO;
}

+ (SocketIO *)socketIO{
    return socketIO;
}

//+ (void)logout{
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    
//    NSString *url = [NSString stringWithFormat:@"http://%@:%d/logout", kFZZSocketHost, kFZZSocketPort];
//    
//    [request setHTTPMethod:@"GET"];
//    [request setURL:[NSURL URLWithString:url]];
//    
//    NSError *error = [[NSError alloc] init];
//    NSHTTPURLResponse *responseCode = nil;
//    
//    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
//    
//    if([responseCode statusCode] != 200){
//        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
//        return;
//    }
//    
//    didAjax = NO;
//    NSLog(@"Logged out");
//    
//    
//    NSLog(@"%@",[[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding]);
//}

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
    NSHTTPURLResponse *resp= (NSHTTPURLResponse *) response;
    NSLog(@"got response with status @push %ld",(long)[resp statusCode]);
    
    if ([resp statusCode] == 200){
        didAjax = YES;
        [FZZSocketIODelegate openConnectionCheckingForInternet];
    } else {
        // AJAX failed
        
        FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
        
        [appDelegate promptForNewFacebookToken];
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


- (void) openConnection{
    resignedActive = NO;
    
    if (didAjax){
        [socketIO connectToHost:kFZZSocketHost onPort:kFZZSocketPort];
    } else {
        if (![delegate ajaxPostRequest]){
            // Get the fb token and post an AJAX Request Again
            
            /* TODOAndrew Reconnect has issues, especially if you fail to connect in the first place */
        }
    }
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
        [delegate performSelector:@selector(reconnect) withObject:nil afterDelay:reconnectDelay];
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
    [socketIO disconnect];
    [FZZSocketIODelegate openConnectionCheckingForInternet];
    NSLog(@"OPENCONN 2");
}

+ (void) willResignActive{
    resignedActive = YES;
    
    if (connected){
        [socketIO disconnect];
        connected = NO;
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:delegate];
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
            [delegate performSelectorInBackground:function withObject:args];
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
    
    // User array
    NSDictionary *invitees = [json objectForKey:@"invitees"];
    
    // uid arrays
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

- (void)incomingCompletedEvent:(NSArray *)args{
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
    
    NSDictionary *messageDict = [json objectForKey:@"message"];
    
    FZZMessage *message = [FZZMessage parseJSON:messageDict];
    
    FZZEvent *event = [message event];
    
    [event updateAddMessage:message];

//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    FZZEventsExpandedViewController *eevc = [appDelegate eevc];
//    
//    [eevc addIncomingMessageForEvent:event];
}

- (void)incomingUpdateClusters:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSNumber *eID = [json objectForKey:@"eid"];
    
    NSArray *clustersJSON = [json objectForKey:@"clusters"];
    
    NSArray *localClusters = [FZZCluster parseClusterJSONList:clustersJSON];
    
    FZZEvent *event = [FZZEvent eventWithEID:eID];
    [event updateClusters:localClusters];
}

- (void)incomingUpdateLocation:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSNumber *eid = [json objectForKey:@"eid"];
    
    NSString *location = [json objectForKey:@"location"];
    
    FZZEvent *event = [FZZEvent eventWithEID:eid];
    
    [event setLocation:location];
}

- (void)incomingUpdateTime:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSNumber *eid = [json objectForKey:@"eid"];
    
    NSNumber *time = [json objectForKey:@"time"];
    
    NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970:[time integerValue]];
    
    FZZEvent *event = [FZZEvent eventWithEID:eid];
    
    [event setTime:dateTime];
}

- (void)incomingUpdateEvent:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSNumber *eid = [json objectForKey:@"eid"];
    
    NSString *description = [json objectForKey:@"descriptions"];
    
    FZZEvent *event = [FZZEvent eventWithEID:eid];
    
    // Update visually too
    [event updateDescription:description];
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

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
#import "FZZLocationManager.h"

#import "FZZContactDelegate.h"
#import "FZZContactSelectionDelegate.h"

#import "FZZLocalCache.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

NSString * const FZZ_INCOMING_ON_LOGIN = @"onLogin";
NSString * const FZZ_INCOMING_NEW_EVENT = @"newEvent";
NSString * const FZZ_INCOMING_COMPLETE_EVENT = @"completeEvent";
NSString * const FZZ_INCOMING_UPDATE_GUESTS = @"updateGuests";
NSString * const FZZ_INCOMING_NEW_INVITEES = @"newInvitees";
NSString * const FZZ_INCOMING_NEW_MESSAGE = @"newMessage";
NSString * const FZZ_INCOMING_UPDATE_EVENT = @"updateEvent";

static BOOL hasMadeDelegate = NO;
static FZZSocketIODelegate *socketIODelegate;

static SocketIO *socketIO;

static NSDictionary *incomingEventResponses;

static int reconnectDelay;
static BOOL resignedActive;
static NSMutableData *data;

static NSDate *loginTimestamp;

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
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewInvitees:))
                                  forKey:FZZ_INCOMING_NEW_INVITEES];
        
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
    NSLog(@"did send body %@", connection);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [data setLength:0];
    
    if ([FZZAjaxPostDelegate connection:connection didRecieveResponse:response]){
        [[FZZSocketIODelegate socketIODelegate] openConnection];
    } else {
        NSLog(@"CONNECTION: <<%@>> RESPONSE: <<%@>>", connection, response);
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
    NSLog(@"\n[socketIO] Connection Opened\n");
    reconnectDelay = kFZZDefaultReconnectDelay;
}

/* Disconnect */

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error{
    NSLog(@"\n[socketIO] Connection Disconnected\n");
    if (!resignedActive){ NSLog(@"\n[socketIO] Attempting to Reconnect\n");
        [socketIODelegate performSelector:@selector(reconnect) withObject:nil afterDelay:reconnectDelay];
    }
}

- (void) updateReconnectDelay{
    // Ramp up how often you try to reconnect from every 5 seconds to every 5 minutes
    if (reconnectDelay < kFZZMaximumReconnectDelay){
        reconnectDelay += ((reconnectDelay / 20.0) + 1.0) * 5.0;
        
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
    
    if ([socketIO isConnected]){
        [[FZZSocketIODelegate socketIO] disconnect];
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
    
    //
    NSArray *eventChangesList = [json objectForKey:@"eventList"];
    
    NSSet *unusableEventIDs = [FZZEvent confirmEventsAndNumberOfMessages:eventChangesList];
    
    NSMutableArray *eventIDList = [[NSMutableArray alloc] init];
    NSMutableArray *eventIDsToComplete = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [eventChangesList count]; ++i){
        NSDictionary *dict = [eventChangesList objectAtIndex:i];
        NSNumber *eventID = [dict objectForKey:@"eid"];
        
        [eventIDList addObject:eventID];
        
        NSNumber *shouldComplete = [dict objectForKey:@"completed"];
        
        if ([shouldComplete boolValue]){
            [eventIDsToComplete addObject:eventID];
        }
    }
    
    NSDictionary *messageDictJSON = [json objectForKey:@"newMessages"];
    
    // User array (additive)
    NSDictionary *invitees = [json objectForKey:@"newInvitees"];
    
    // uid arrays (absolute)
    NSDictionary *guests   = [json objectForKey:@"guests"];
    
    // complete Events
    [FZZEvent killEvents:eventIDsToComplete];
    
    // Events
//    NSSet *unparsedEventIDs = [FZZEvent parseOnLoginEventList:eventIDList];
    
    // Messages
    // Parses the JSON, places messages in the appropriate events
    NSDictionary *messageCounts = [FZZMessage parseMessageJSONDict:messageDictJSON];
    
    /* Handle invitees before guests  */
    // newInvitees
    
    [invitees enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *eventID = [NSNumber numberWithInt:[(NSString *)key intValue]];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        NSArray *updatedInvitees = (NSArray *)obj;
        
        updatedInvitees = [FZZUser parseUserJSONList:(NSArray *)obj];
        
        [event updateAddInvitees:updatedInvitees];
    }];
    
    // guests
    [guests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *eventID = [NSNumber numberWithInt:[(NSString *)key intValue]];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        NSArray *updatedGuests = [FZZUser getUsersFromUIDs:(NSArray *)obj];
        
        [event updateGuests:updatedGuests];
    }];
    
    // TODOAndrew Update visual elements!
    
    // After all users are loaded in, update available friends to invite
    // TODOAndrew Check out what update friends is doing, cache the friendslist?

    [appDelegate updateEvents];
    [FZZContactDelegate updateFriendsAndContacts];
    
    loginTimestamp = [NSDate date];
}

- (void)incomingNewEvent:(NSArray *)args{
    NSLog(@"\n\nINCOMING NEW EVENT: %@\n", args);
    
    NSDictionary *json  = [args objectAtIndex:0];
    
    FZZEvent *event = [FZZEvent parseJSON:json];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate updateEvents];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:event forKey:@"event"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FZZ_INCOMING_NEW_EVENT
                                                        object:self
                                                      userInfo:dict];
}

- (void)incomingCompleteEvent:(NSArray *)args{
    NSDictionary *json = [args objectAtIndex:0];
    
    NSNumber *eID = [json objectForKey:@"eid"];
    
    [FZZEvent killEvents:[NSArray arrayWithObject:eID]];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate updateEvents];
}

- (void)incomingUpdateGuests:(NSArray *)args{
    NSDictionary *json = [args objectAtIndex:0];
    
    NSNumber *eID = [json objectForKey:@"eid"];
    FZZEvent *event = [FZZEvent eventWithEID:eID];
    
    NSArray *guestIDs = [json objectForKey:@"guests"];
    
    NSArray *guests = [FZZUser getUsersFromUIDs:guestIDs];
    
    NSLog(@"INCOMING GUEST IDS: %@", guestIDs);
    NSLog(@"INCOMING GUESTS: %@", guests);
    
    [event updateGuests:guests];
    
    // TODOAndrew don't invalidate all guest invitation lists, just the updated events
    [FZZContactSelectionDelegate invalidateInvitables];
}

- (void)incomingNewInvitees:(NSArray *)args{
    NSDictionary *json = [args objectAtIndex:0];
    
    NSNumber *eventID = [json objectForKey:@"eid"];
    FZZEvent *event = [FZZEvent eventWithEID:eventID];
    
    NSLog(@"JSON: %@", json);
    
    NSArray *invitees = [json objectForKey:@"newlyInvitedUsers"];
    
    NSLog(@"UNPARSED INVITEES: %@", invitees);
    
    invitees = [FZZUser parseUserJSONList:invitees];
    
    NSLog(@"PARSED INVITEES: %@", invitees);
    
    [event updateAddInvitees:invitees];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FZZ_INCOMING_NEW_INVITEES object:nil userInfo:nil];
}

- (void)incomingNewMessage:(NSArray *)args{
    
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSLog(@"NEW MESSAGE: %@", json);
    
    NSDictionary *messageDict = [json objectForKey:@"message"];
    
    FZZMessage *message = [FZZMessage parseJSON:messageDict];
    
    FZZEvent *event = [message event];

    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [event updateAddMessage:message];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FZZ_INCOMING_NEW_MESSAGE object:nil userInfo:nil];
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
    return [socketIO isConnected];
}


+(BOOL)recentLogin{
    NSLog(@"TIME PASSED: %f", [loginTimestamp timeIntervalSinceNow]);
    
    if (!loginTimestamp || (-[loginTimestamp timeIntervalSinceNow]) < 1){
        return YES;
    }
    
    return NO;
}

@end

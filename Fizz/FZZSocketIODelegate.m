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

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

static NSString *FZZ_INCOMING_ON_LOGIN = @"onLogin";
static NSString *FZZ_INCOMING_NEW_EVENTS = @"newEvents";
static NSString *FZZ_INCOMING_NEW_SUGGESTED_INVITES = @"newSuggestedInvites";
static NSString *FZZ_INCOMING_TO_ATTENDEES = @"toAttendees";
static NSString *FZZ_INCOMING_TO_GUESTS = @"toGuests";
static NSString *FZZ_INCOMING_TO_INVITEES = @"toInvitees";
static NSString *FZZ_INCOMING_NEW_MESSAGES = @"newMessages";
static NSString *FZZ_INCOMING_SET_SEAT_CAPACITY = @"setSeatCapacity";

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
    if (self == [NSObject class]) {
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
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewEvents:))
                                  forKey:FZZ_INCOMING_NEW_EVENTS];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewSuggestedInvites:))
                                  forKey:FZZ_INCOMING_NEW_SUGGESTED_INVITES];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingToAttendees:))
                                  forKey:FZZ_INCOMING_TO_ATTENDEES];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingToGuests:))
                                  forKey:FZZ_INCOMING_TO_GUESTS];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingToInvitees:))
                                  forKey:FZZ_INCOMING_TO_INVITEES];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingNewMessages:))
                                  forKey:FZZ_INCOMING_NEW_MESSAGES];
        
        [incomingEventResponses setValue:NSStringFromSelector(@selector(incomingSetSeatCapacity:))
                                  forKey:FZZ_INCOMING_SET_SEAT_CAPACITY];
    }
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
        
        [delegate performSelector:@selector(openConnectionCheckingForInternet) withObject:nil afterDelay:reconnectDelay];
        
        [delegate updateReconnectDelay];
    }
}

/* AJAX */

- (BOOL)ajaxPostRequest{
    NSLog(@"AJAX REQUEST");
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDelegate.isConnecting = YES;
    
    NSString *fbToken = [FBSession activeSession].accessTokenData.accessToken;
//    NSString *phoneNumber = [appDelegate userPhoneNumber]; //("+" followed by just digits)
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSString *iosToken = [pref objectForKey:@"iosToken"];
    
    NSString *phoneNumber = [pref objectForKey:@"phoneNumber"];
    
//    appDelegate.userPhoneNumber = NULL;
    
    if (fbToken){
        
        NSLog(@"sending AJAX");
        
        // FB Session Token
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
        
        [keys addObject:@"version"];
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
        [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
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
    NSLog(@"got response with status @push %d",[resp statusCode]);
    
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
    {
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isConnecting = NO;
    }
    
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSDictionary *userJSON   = [json objectForKey:@"me"];
    NSArray *friendListJSON  = [json objectForKey:@"newFriendList"];
    NSArray *eventListJSON   = [json objectForKey:@"newEventList"];
    NSArray *messageListJSON = [json objectForKey:@"newMessageList"];
    NSString *fbAccessToken  = [json objectForKey:@"fbToken"];
    NSDictionary *friendScoreMap = [json objectForKey:@"friendScoreMap"];
    
    // uid arrays
    NSDictionary *attendees   = [json objectForKey:@"attendees"];
    NSDictionary *guests      = [json objectForKey:@"guests"];
    
    // User array
    NSDictionary *newInvitees = [json objectForKey:@"newInvitees"];
    
    
    // User (me)
    
    FZZUser *me = [FZZUser parseJSON:userJSON];
    
    [FZZUser setMeAs:me];
    
    
    // User Array (friends)
    NSArray *newFriends = [FZZUser parseUserJSONFriendList:friendListJSON];
    
    [FZZInviteViewController updateFriends];
    
    
    // Events
    NSArray *newEvents = [FZZEvent parseEventJSONList:eventListJSON];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate updateEvents:newEvents];
    
    
    // Messages
    NSArray *newMessages = [FZZMessage parseMessageJSONList:messageListJSON];
    
    
    // Facebook Access Token
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:fbAccessToken forKey:@"fbToken"];
    
    
    // friendScoreMap
    
    
    /* Handle invitees first in order  */
    // newInvitees
    [guests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *eventID = [NSNumber numberWithInt:[(NSString *)key intValue]];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        NSArray *newUsers = (NSArray *)obj;
        
        [event updateAddInvitees:newUsers];
    }];
    
    // attendees
    [attendees enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *eventID = [NSNumber numberWithInt:[(NSString *)key intValue]];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        NSArray *newUsers = [FZZUser parseUserJSONList:(NSArray *)obj];
        
        [event updateAtEvent:newUsers];
    }];
    
    // guests
    [guests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *eventID = [NSNumber numberWithInt:[(NSString *)key intValue]];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        NSArray *newUsers = [FZZUser parseUserJSONList:(NSArray *)obj];
        
        [event updateGuests:newUsers];
    }];
    
}

- (void)incomingNewEvents:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSArray *data = [json objectForKey:@"data"];
    
    NSArray *newEvents = [FZZEvent parseEventJSONList:data];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateEvents:newEvents];
}

- (void)incomingNewSuggestedInvites:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSArray *data = [json objectForKey:@"data"];
    
    NSArray *newSuggested = [FZZUser parseUserJSONList:data];
    
//    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)incomingToAttendees:(NSArray *)args{
    NSDictionary *json = [args objectAtIndex:0];
    
    NSDictionary *data = [json objectForKey:@"data"];
    
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *eventID = [NSNumber numberWithInt:[(NSString *)key intValue]];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        NSArray *toAttendees = obj;
        
        [event updateToAttendees:toAttendees];
    }];
}

- (void)incomingToGuests:(NSArray *)args{
    NSDictionary *json = [args objectAtIndex:0];
    
    NSDictionary *data = [json objectForKey:@"data"];
    
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *eventID = [NSNumber numberWithInt:[(NSString *)key intValue]];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        NSArray *toGuests = obj;
        
        [event updateToGuests:toGuests];
    }];
}

- (void)incomingToInvitees:(NSArray *)args{
    NSDictionary *json = [args objectAtIndex:0];
    
    NSDictionary *data = [json objectForKey:@"data"];
    
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *eventID = [NSNumber numberWithInt:[(NSString *)key intValue]];
        FZZEvent *event = [FZZEvent eventWithEID:eventID];
        
        NSArray *toInvitees = obj;
        
        [event updateToInvitees:toInvitees];
    }];
}

                                                              
- (void)incomingSetSeatCapacity:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    // Event ID
    NSNumber *eventID = [json objectForKey:@"eid"];
    
    // Num Seats
    NSNumber *numSeats = [json objectForKey:@"seats"];
    
    FZZEvent *event = [FZZEvent eventWithEID:eventID];
    
    [event updateNumberOfSeats:numSeats];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate.esvc updateEvent:event];
}

- (void)incomingNewMessages:(NSArray *)args{
    NSDictionary *json  = [args objectAtIndex:0];
    
    NSArray *data = [json objectForKey:@"data"];
    
    NSArray *messages = [FZZMessage parseMessageJSONList:data];
    
    FZZAppDelegate *appDelegate = (FZZAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [messages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZMessage *message = obj;
        FZZEvent *event = [message event];
        
        [event updateAddMessage:message];
        
//        [appDelegate.esvc addIncomingMessageForEvent:event];
    }];
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


@end

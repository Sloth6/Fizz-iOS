//
//  FZZAppDelegate.m
//  Fizz
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import "FZZAppDelegate.h"
#import "FZZUser.h"
#import "SBJson4.h"
#import "FZZEvent.h"
#import "FZZLoginViewController.h"
#import "FZZEventsExpandedViewController.h"
#import "FZZInviteViewController.h"
#import "FZZBubbleViewController.h"

#import "FZZMessage.h"

#import "FZZCoreDataStore.h"

#import "FZZOverlayView.h"

#import "TestFlight.h"

@implementation FZZAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize fbLoginDelegate;

- (void)setupNavigationBar{
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGRect navBarRect = CGRectMake(0, 0, screenWidth, 80);
    
    self.navigationBar = [[FZZOverlayView alloc] initWithFrame:navBarRect];
    [self addSearchBar];
}

- (void)addSearchBar{
    float x = 60;
    float y = 12;
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGRect frame = CGRectMake(x, y, screenWidth - (2 * x) - 14, 60);
    
    _searchTextField = [[UITextField alloc] initWithFrame:frame];
    
    [_searchTextField setFont:[UIFont fontWithName:@"HelveticaNeue" size:18.0]];
//    [_searchTextField setSearchBarStyle:UISearchBarStyleMinimal];
    [_searchTextField setPlaceholder:@"Search"];
    
    [_searchTextField setHidden:YES];
}

- (void)setupNavigationController{
    
//    _esvc.automaticallyAdjustsScrollViewInsets = NO;
    
    UINavigationController *navigationController = [[UINavigationController alloc]
                                initWithRootViewController:_eevc];
   
    [navigationController setNavigationBarHidden:YES];
    
//    navigationController.automaticallyAdjustsScrollViewInsets = NO;
    [self.window setRootViewController:navigationController];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    _bvc = [[FZZBubbleViewController alloc] init];
    _eevc.bvc = _bvc;
    
    [self.window addSubview:(UIView *)_bvc.bubbleView];
    
    [self.window addSubview:self.navigationBar];
    [self.window addSubview:_searchTextField];
}

- (void)handleDidCrash{
    _hasLoadedDataFromCache = YES;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSNumber *didCrash = [pref objectForKey:@"didCrash"];
    
    // Initial Launch: if didCrash is nil, [didCrash boolValue] returns nil
    if ([didCrash boolValue]){
        
        [FZZCoreDataStore deleteCache];
    }
}

- (void)loadAll{
    NSLog(@"here we go!");
    [FZZEvent fetchAll];
    NSLog(@"here we go 2");
    
    NSArray *events = [FZZEvent getEvents];
    
    NSLog(@"\n\n");
    
    [events enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        FZZEvent *event = obj;
        
        FZZMessage *message = [event firstMessage];
        
        NSLog(@"%@", [message text]);
    }];
    
    NSLog(@"\n\n");
//        [FZZUser fetchAll];
}

- (void)loadDataFromCache{
    _hasLoadedDataFromCache = YES;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSNumber *didCrash = [pref objectForKey:@"didCrash"];
    
    // Initial Launch: if didCrash is nil, [didCrash boolValue] returns nil
    if ([didCrash boolValue]){
        
        NSLog(@"didCrash");
        
        [FZZSocketIODelegate socketIOResetDataFromServerWithAcknowledge:NULL];
        
    } else { // Load data from cache
        
        NSLog(@"Loading all data...");
        
        [self performSelectorOnMainThread:@selector(loadAll) withObject:nil waitUntilDone:YES];
        
        NSLog(@"Successfully loaded all data!");
        
//        IAThreadSafeContext *moc = [self managedObjectContext];
        
//        NSManagedObjectContext *moc = [FZZCoreDataStore privateQueueContext];
//        
//        @synchronized([moc persistentStoreCoordinator]) {
//            [moc performBlock:^{
//                NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FZZEvent"];
//                [fetchRequest setIncludesSubentities:YES];
//                
//                
//                NSArray *results = [moc executeFetchRequest:fetchRequest
//                                                      error:nil];
//                
//                NSLog(@"\n\nCACHED_EVENTS: %@\n\n\n", results);
//                
//                if (results != nil && [results count] > 0){
//                    
//                    for (int i = 0; i < [results count]; ++i) {
//                        FZZEvent *event = [results objectAtIndex:i];
//                        
//                        NSLog(@"firstMessage: %@", [event firstMessage]);
//                    }
//                    
//                    [self updateEvents:results];
//                }
//
//            }];
//        }
    
        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        
//        NSEntityDescription *entity = [NSEntityDescription
//                                       entityForName:@"FZZEvent" inManagedObjectContext:moc];
//        
//        [fetchRequest setIncludesSubentities:YES];
//        
//        [fetchRequest setEntity:entity];
        
//        NSArray *results;
//        NSError *error = nil;
//        results = [moc executeFetchRequest:fetchRequest error:&error];
        
    }
    
    // Make sure to only update didCrash when everything is fixed
    [pref setObject:[NSNumber numberWithBool:NO] forKey:@"didCrash"];
    [pref synchronize];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Install crash handlers
    NSSetUncaughtExceptionHandler(&HandleException);
    
    struct sigaction signalAction;
    memset(&signalAction, 0, sizeof(signalAction));
    signalAction.sa_handler = &HandleSignal;
    
    sigaction(SIGABRT, &signalAction, NULL);
    sigaction(SIGILL, &signalAction, NULL);
    sigaction(SIGBUS, &signalAction, NULL);
    
    // Install TestFlight
    [TestFlight takeOff:@"c57d6a81-8946-4632-977e-9b92f7d0802a"];
    
    [self handleDidCrash];
    
    _hasLoadedDataFromCache = NO;
    _hasLoggedIn = NO;
    
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    [prefs removeObjectForKey:@"phoneNumber"];
//    [prefs removeObjectForKey:@"registered"];
//    [prefs synchronize];
    
    // Create a flow layout for the collection view that scrolls
    // vertically and has no space between items
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
    
    [self setupNavigationBar];
    
    _eevc = [[FZZEventsExpandedViewController alloc] initWithCollectionViewLayout:flowLayout];
    
    [FZZInviteViewController setupClass];
    
    // Load the FBLoginView Class
    [FBLoginView class];
    
    fbLoginDelegate = [[FZZFacebookLoginDelegate alloc] init];
    
    facebookColor = [UIColor colorWithRed:59.0/256.0 green:89.0/256.0 blue:152.0/256.0 alpha:1.0];
    fizzColor = [UIColor colorWithRed:128.0/256.0 green:128.0/256.0 blue:128.0/256.0 alpha:1.0];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    /* Initialize their dictionaries of all existing instances */
    [FZZUser setupUserClass];
    [FZZEvent setupEventClass];
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSNumber *registered = [pref objectForKey:@"registered"];
    [pref synchronize];
    
    BOOL hasRegistered;
    
    if (registered != NULL){
        hasRegistered = [registered boolValue];
    } else {
        hasRegistered = NO;
    }
    
    // Whenever a person opens the app, check for a cached session
    if (hasRegistered &&
        FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        NSLog(@"\n\nActive Session Loaded\n\n");
        
        [FZZSocketIODelegate openConnectionCheckingForInternet];
        [self setupNavigationController];
//         // If there's one, just open the session silently, without showing the user the login UI
//         [FBSession openActiveSessionWithReadPermissions:@[@"user_friends",
//         @"user_groups",
//         @"email",
//         @"xmpp_login"
//         ]
//         allowLoginUI:NO
//         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//         
//             _hasLoggedIn = YES;
//             
//             NSLog(@"\n\n\nFBSession: %@\n\n\n", session);
//             
//             // Handler for session state changes
//             // This method will be called EACH time the session state changes,
//             // also for intermediate states and NOT just when the session open
//             [fbLoginDelegate sessionStateChanged:session state:state error:error];
//         }];
     } else { // Send to Login View Controller
         NSLog(@"\n\nSend To Login View Controller\n\n");
         
         [self promptForNewFacebookToken];
//        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[FZZMapViewController alloc] initWithNibName:@"FZZMapViewController" bundle:Nil]];
     }
    
    
    
    ////self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:_evvc];
    
    
    
    //FZZCollectionView *collectionView = [[FZZCollectionView alloc] initWithFrame:self.window.frame
    //collectionViewLayout:[[UICollectionViewLayout alloc] init]];
    
    
    //FZZScrollViewController *timelineVC = [[FZZScrollViewController alloc] init];
    
    //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:timelineVC];
    
    
    
    
    // Whenever a person opens the app, check for a cached session
    /*if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"user_friends",
                                                          @"user_groups",
                                                          @"email",
                                                          @"xmpp_login"
                                                          ]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          
                                          NSLog(@"\n\n\nFBSession: %@\n\n\n", session);
                                          
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          //[fbLoginDelegate sessionStateChanged:session state:state error:error];
                                          
                                      }];
    } else {*/ // Send to Login View Controller
        //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[FZZMapViewController alloc] initWithNibName:@"FZZMapViewController" bundle:Nil]];
    //}
    
    /*
     self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[FZZLoginViewController alloc] initWithNibName:@"FZZLoginViewController" bundle:Nil]];
     */
    
    NSDictionary *remoteNotif = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //Accept push notification when app is not open
    if (remoteNotif) {
        [self application:application didReceiveRemoteNotification:remoteNotif];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // app was already in the foreground
    if ( application.applicationState == UIApplicationStateActive)
    {
//        NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
//        
//        NSString *alertMsg = @"";
//        NSString *badge = @"";
//        NSString *sound = @"";
//        NSString *custom = @"";
//        
//        if( [apsInfo objectForKey:@"alert"] != NULL)
//        {
//            alertMsg = [apsInfo objectForKey:@"alert"];
//        }
//        
//        
//        if( [apsInfo objectForKey:@"badge"] != NULL)
//        {
//            badge = [apsInfo objectForKey:@"badge"];
//        }
//        
//        
//        if( [apsInfo objectForKey:@"sound"] != NULL)
//        {
//            sound = [apsInfo objectForKey:@"sound"];
//        }
//        
//        if( [userInfo objectForKey:@"Type"] != NULL)
//        {
//            custom = [userInfo objectForKey:@"Type"];
//        }
//        
//        // Set your appending text.
//        NSString *textToAdd = [NSString stringWithFormat:@":%@", alertMsg];
//        
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        NSString *fileName = [NSString stringWithFormat:@"%@/AccountNotifications.txt", documentsDirectory];
//        NSString *fileContents = [[NSString alloc]  initWithContentsOfFile:fileName usedEncoding:nil error:nil];
//        
//        NSString *textToFile;
//        
//        if (fileContents == NULL)
//        {
//            textToFile = alertMsg;
//        }
//        
//        // Here you append new text to the existing one
//        if (fileContents != NULL)
//        {
//            textToFile = [fileContents stringByAppendingString:textToAdd];
//        }
//        
//        // Here you save the updated text to that file
//        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        documentsDirectory = [paths objectAtIndex:0];
//        fileName = [NSString stringWithFormat:@"%@/AccountNotifications.txt", documentsDirectory];
//        NSString *content = textToFile;
//        [content writeToFile:fileName atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
//        
//        NSArray *fileData = [textToFile componentsSeparatedByString:@":"];
//        
//        NSMutableArray *tableDataFromFile;
//        tableDataFromFile = [[NSMutableArray alloc] init];
//        
//        int i = 0;
//        
//        for (i = 1; i < [fileData count]; i++)
//        {
//            [tableDataFromFile addObject:fileData[i]];
//        }
//        
//        NotificationViewController *vc = [[NotificationViewController alloc] initWithNibName:@"NotificationViewController" bundle:nil];
//        vc.tableData = tableDataFromFile;
//        
//        UIViewController *root = self.mainNavController.topViewController;
//        NSArray *vcs = [NSArray arrayWithObjects:root, vc, nil];
//        [self.mainNavController setViewControllers:vcs animated:YES];
    }
    // app was just brought from background to foreground
    else
    {
        //NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
        
        NSNumber *eid = [userInfo objectForKey:@"eid"];
        
        NSLog(@"Loading From Push To Event: %@", eid);
        
        if (eid){
            FZZEvent *event = [FZZEvent eventWithEID:eid];
            
            [_eevc loadToEvent:event];
        }
    }
}

- (void)promptForNewFacebookToken{
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[FZZLoginViewController alloc] initWithNibName:@"FZZLoginViewController" bundle:nil]];
}

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url != nil)
    {
        // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
        BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        
        // You can add your app-specific url handling code here if needed
        
        return wasHandled;
        
        //return [[FBSession activeSession] handleOpenURL:url];
    }
    
    return NO;
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *tokenString = [self stringWithDeviceToken:deviceToken];
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:tokenString forKey:@"iosToken"];
    [pref synchronize];
    
    NSLog(@"\n\nDevice Token: <%@>\n\n", tokenString);
}

- (NSString*)stringWithDeviceToken:(NSData*)deviceToken {
    const char* data = [deviceToken bytes];
    NSMutableString* token = [NSMutableString string];
    
    for (int i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }
    
    return [token copy];
}

- (void)reclaimBubbleView{
    [(UIView *)_bvc.bubbleView removeFromSuperview];
    [self.window addSubview:(UIView *)_bvc.bubbleView];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [FZZSocketIODelegate willResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"Saving context");
    [self saveContext];
    NSLog(@"Did save context");
    
//    [[FZZCoordinate alloc] initWithLongitude:1 andLatitude:2];
//    
//    [FZZDataStore synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    _gotAddressBook = NO;
    
    if ((![FZZSocketIODelegate isConnectionOpen]) && _hasLoggedIn && !_isConnecting){
//    if ((![ioSocketDelegate isConnectionOpen]) && !_hasLoggedIn){
        NSLog(@"Connection is not open");
        [FZZSocketIODelegate openConnectionCheckingForInternet];
    }
    
//        [[FBSession activeSession] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"Saving context");
    [self saveContext];
    NSLog(@"Did save context");
//    [[FBSession activeSession] close];
}

+ (BOOL)isRetinaDisplay{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)]
    && [[UIScreen mainScreen] scale] == 2.0;
}

- (void)updateEvents:(NSArray *)events{
    [_eevc updateEvents:[events mutableCopy]];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [FZZCoreDataStore getAppropriateManagedObjectContext];
    
    @synchronized(managedObjectContext){
        if (managedObjectContext != nil) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}

#pragma mark - Crash Handlers

void HandleException(NSException *exception) {
    NSLog(@"App crashing with exception: %@", exception);
    //Save somewhere that your app has crashed.
    //Note this on launch, so that I can query the server for a clean slate of data
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:[NSNumber numberWithBool:YES] forKey:@"didCrash"];
    [pref synchronize];
}

void HandleSignal(int signal) {
    NSLog(@"We received a signal: %d", signal);
    //Save somewhere that your app has crashed.
    //Note this on launch, so that I can query the server for a clean slate of data
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:[NSNumber numberWithBool:YES] forKey:@"didCrash"];
    [pref synchronize];
}

@end

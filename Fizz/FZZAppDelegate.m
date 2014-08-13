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
#import "FZZEventsViewController.h"
#import "FZZInviteViewController.h"
#import "FZZLocalCache.h"
#import "FZZLocationManager.h"
#import "FZZUtilities.h"

#import "FZZLoginDelegate.h"

#import "FZZInputPhoneViewController.h"

#import "FZZMessage.h"

#import "FZZOverlayView.h"

#import "TestFlight.h"

@implementation FZZAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

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
                                initWithRootViewController:_evc];
   
    [navigationController setNavigationBarHidden:YES];
    
//    navigationController.automaticallyAdjustsScrollViewInsets = NO;
    [self.window setRootViewController:navigationController];
    [self.window setBackgroundColor:[UIColor clearColor]];
    
    [self.window addSubview:self.navigationBar];
    [self.window addSubview:_searchTextField];
}

- (void)loadDataFromCache{
    _hasLoadedDataFromCache = YES;
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSNumber *didCrash = [pref objectForKey:@"didCrash"];
    
    // Initial Launch: if didCrash is nil, [didCrash boolValue] returns nil
    if ([didCrash boolValue]){
        
        NSLog(@"didCrash");
        
        [FZZLocalCache clearCache];
        [FZZSocketIODelegate socketIOResetDataFromServerWithAcknowledge:NULL];
        
    } else { // Load data from cache
        
        NSLog(@"Loading all data...");
        
        if ([FZZLocalCache loadFromCache]){
            NSLog(@"Successfully loaded all data!");
            
            if ([FZZLocalCache containsInvalidData]){
                [FZZLocalCache clearCache];
                [FZZSocketIODelegate socketIOResetDataFromServerWithAcknowledge:NULL];
            }
            
        } else {
            NSLog(@"No cached data exists.");
        }
        
        
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
    
    @synchronized([FZZEvent class]){
        [self loadDataFromCache];
    }
    
    // Initialize Class Variables
    [FZZUtilities class];
    
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
    
    _evc = [[FZZEventsViewController alloc] initWithCollectionViewLayout:flowLayout];
    
    [FZZInviteViewController setupClass];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    
    /* Initialize their dictionaries of all existing instances */
    [FZZUser setupUserClass];
    [FZZEvent setupEventClass];
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    NSNumber *registered = [pref objectForKey:@"didRegister"];
    
    BOOL hasRegistered;
    
    if (registered != nil){
        hasRegistered = [registered boolValue];
    } else {
        hasRegistered = NO;
    }
    
    // Whenever a person opens the app, check for a cached session
    if (hasRegistered) {
        NSLog(@"\n\nActive Session Loaded\n\n");
        
        [FZZSocketIODelegate openConnectionCheckingForInternet];
        [self setupNavigationController];

    } else { // Send to Login View Controller
         NSLog(@"\n\nSend To Login View Controller\n\n");
         
         [self promptForRegistration];
    }
    
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
            
            [_evc loadToEvent:event];
        }
    }
}

- (void)promptForRegistration{
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[FZZInputPhoneViewController alloc] initWithNibName:@"FZZInputPhoneViewController" bundle:nil]];
}

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return NO;
    
    if (url != nil)
    {
        // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
//        BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
        
        // You can add your app-specific url handling code here if needed
        
//        return wasHandled;
        
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
    
    NSLog(@"Updating local cache...");
    if ([FZZLocalCache updateCache]){
        NSLog(@"Did update cache.");
    } else{
        NSLog(@"Failed to update cache.");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    _gotAddressBook = NO;
    
    if ((![FZZSocketIODelegate isConnectionOpen]) && _hasLoggedIn && !_isConnecting){
        NSLog(@"Connection is not open");
        [FZZSocketIODelegate openConnectionCheckingForInternet];
    } else {
        NSLog(@"!isConnectionOpen: %d, hasLoggedIn: %d, !isConnecting: %d", (![FZZSocketIODelegate isConnectionOpen]), _hasLoggedIn, !_isConnecting);
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"Updating local cache...");
    if ([FZZLocalCache updateCache]){
        NSLog(@"Did update cache.");
    } else {
        NSLog(@"Failed to update cache.");
    }
}

+ (BOOL)isRetinaDisplay{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)]
    && [[UIScreen mainScreen] scale] == 2.0;
}

// Called when an event has been removed or added
- (void)updateEvents{
    [_evc updateEvents];
    
    NSLog(@"Updating local cache...");
    if ([FZZLocalCache updateCache]){
        NSLog(@"Did update cache.");
    } else {
        NSLog(@"Failed to update cache.");
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

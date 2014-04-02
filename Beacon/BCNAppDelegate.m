//
//  BCNAppDelegate.m
//  Beacon
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import "BCNAppDelegate.h"
#import "BCNUser.h"
#import "SBJson4.h"
#import "BCNEvent.h"
#import "BCNLoginViewController.h"
#import "BCNEventStreamViewController.h"
#import "BCNInviteViewController.h"
#import "BCNBubbleViewController.h"
#import "BCNParallaxViewController.h"

#import "BCNNavigationBar.h"

@implementation BCNAppDelegate

@synthesize ioSocketDelegate, fbLoginDelegate;

- (void)setupNavigationBar{
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGRect navBarRect = CGRectMake(0, 0, screenWidth, 80);
    
    self.navigationBar = [[BCNNavigationBar alloc] initWithFrame:navBarRect];
}

- (void)setupNavigationController{

//    _esvc.automaticallyAdjustsScrollViewInsets = NO;
    
    UINavigationController *navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:_esvc];
    
    [navigationController setNavigationBarHidden:YES];
    
//    navigationController.automaticallyAdjustsScrollViewInsets = NO;
    self.window.rootViewController = navigationController;
    
    _bvc = [[BCNBubbleViewController alloc] init];
    _esvc.bvc = _bvc;
    
    _pvc = [[BCNParallaxViewController alloc] init];
    _esvc.pvc = _pvc;
    
    [self.window addSubview:(UIView *)_bvc.bubbleView];
    
    // Add the parallax text view on top of this
//    [self.window addSubview:_pvc.tableView];
    
    [self.window addSubview:self.navigationBar];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _hasLoggedIn = NO;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"phoneNumber"];
    [prefs removeObjectForKey:@"registered"];
    [prefs synchronize];
    
    // Create a flow layout for the collection view that scrolls
    // vertically and has no space between items
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
    
    [self setupNavigationBar];
    
    _esvc = [[BCNEventStreamViewController alloc] initWithCollectionViewLayout:flowLayout];
    
    
    [BCNInviteViewController setupClass];
    
    // Load the FBLoginView Class
    [FBLoginView class];
    
    ioSocketDelegate = [[BCN_IOSocketDelegate alloc] init];
    fbLoginDelegate = [[BCNFacebookLoginDelegate alloc] init];
    
    facebookColor = [UIColor colorWithRed:59.0/256.0 green:89.0/256.0 blue:152.0/256.0 alpha:1.0];
    beaconColor = [UIColor colorWithRed:128.0/256.0 green:128.0/256.0 blue:128.0/256.0 alpha:1.0];
    
    [BCNObject setIOSocketDelegate:ioSocketDelegate];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    /* Initialize their dictionaries of all existing instances */
    [BCNUser setupUserClass];
    [BCNEvent setupEventClass];
    
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
        
        [ioSocketDelegate openConnectionCheckingForInternet];
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
//        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BCNMapViewController alloc] initWithNibName:@"BCNMapViewController" bundle:Nil]];
     }
    
    
    
    ////self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:_evvc];
    
    
    
    //BCNCollectionView *collectionView = [[BCNCollectionView alloc] initWithFrame:self.window.frame
    //collectionViewLayout:[[UICollectionViewLayout alloc] init]];
    
    
    //BCNScrollViewController *timelineVC = [[BCNScrollViewController alloc] init];
    
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
        //self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BCNMapViewController alloc] initWithNibName:@"BCNMapViewController" bundle:Nil]];
    //}
    
    /*
     self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BCNLoginViewController alloc] initWithNibName:@"BCNLoginViewController" bundle:Nil]];
     */
    
    return YES;
}

- (void)promptForNewFacebookToken{
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BCNLoginViewController alloc] initWithNibName:@"BCNLoginViewController" bundle:nil]];
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
    NSMutableDictionary *contents = [[NSMutableDictionary alloc] init];
    [contents setObject:[self stringWithDeviceToken:deviceToken] forKey:@"deviceToken"];
    NSDictionary *wrapper = [[NSDictionary alloc] initWithObjectsAndKeys:contents, @"registerForPushNotifications", nil];
    
    SBJson4Writer *writer = [[SBJson4Writer alloc] init];
    NSString *json = [writer stringWithObject:wrapper];
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:[self stringWithDeviceToken:deviceToken] forKey:@"iosToken"];
    [pref synchronize];
    
    NSLog(@"\n\nDevice Token: <%@>\n\n", [contents objectForKey:@"deviceToken"]);
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
    [self.window addSubview:(UIView *)_bvc.bubbleView];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [ioSocketDelegate willResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    _gotAddressBook = NO;
    
    if ((![ioSocketDelegate isConnectionOpen]) && _hasLoggedIn && !_isConnecting){
//    if ((![ioSocketDelegate isConnectionOpen]) && !_hasLoggedIn){
        NSLog(@"Connection is not open");
        [ioSocketDelegate openConnectionCheckingForInternet];
    }
    
//        [[FBSession activeSession] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
//    [[FBSession activeSession] close];
}

+ (BOOL)isRetinaDisplay{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)]
    && [[UIScreen mainScreen] scale] == 2.0;
}

- (void)updateEvents:(NSArray *)events{
    [_esvc updateEvents:[events mutableCopy]];
}

@end

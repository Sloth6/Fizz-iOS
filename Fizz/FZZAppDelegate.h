//
//  FZZAppDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//


/*
 
 This is the App Delegate. It defines constants and acts as a means of accessing other instantiated view controllers from a given view controller. It's a very global way of thinking, and adding to it should be avoided if possible.
 
 [TODO (5/13/14)] Reduce the number of dependencies upon the FZZAppDelegate. This code gets around, and is used pretty much everywhere. Having that many things depend upon it dramatically reduced modularity, and use of global-ish objects often lead to untracked race conditions and other issues.
 
 */

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "FZZSocketIODelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FZZFacebookLoginDelegate.h"
#import "FZZEventsExpandedViewController.h"
#import "FZZEventsCondensedViewController.h"
#import "FZZOverlayView.h"

static const UIColor *facebookColor;
static const UIColor *fizzColor;

static float const kFZZCreatorProfilePictureWidth = 50;
static float const kFZZCreatorProfilePictureHeight = 50;
static float const kFZZCommentProfilePictureWidth = 50;
static float const kFZZCommentProfilePictureHeight = 50;
static float const kFZZInviteProfilePictureWidth = 50;
static float const kFZZInviteProfilePictureHeight = 50;

@class FZZBubbleViewController;

@interface FZZAppDelegate : UIResponder <UIApplicationDelegate, SocketIODelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) FZZFacebookLoginDelegate *fbLoginDelegate;
@property (strong, nonatomic) FZZEventsExpandedViewController *esvc;
@property (strong, nonatomic) FZZEventsCondensedViewController *ocvc;
@property (strong, nonatomic) FZZBubbleViewController *bvc;

@property (strong, nonatomic) FZZOverlayView *navigationBar;
@property (strong, nonatomic) UITextField *searchTextField;

@property BOOL hasLoggedIn;
@property BOOL isConnecting;
@property BOOL gotAddressBook;

@property (strong, nonatomic) NSString *userPhoneNumber;

+ (BOOL)isRetinaDisplay;
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;
- (void)setupNavigationController;
- (void)promptForNewFacebookToken;

- (void)reclaimBubbleView;

// Server Handlers, recieving and handing out information
- (void)updateEvents:(NSArray *)events;


// Core Data

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

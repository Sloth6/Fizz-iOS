//
//  FZZAppDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//


/*
 
 This is the App Delegate. It defines constants and acts as a means of accessing other instantiated view controllers from a given view controller. It's a very global way of thinking, and adding to it should be avoided if possible.
 
 [TODOAndrew (5/13/14)] Reduce the number of dependencies upon the FZZAppDelegate. This code gets around, and is used pretty much everywhere. Having that many things depend upon it dramatically reduced modularity, and use of global-ish objects often lead to untracked race conditions and other issues.
 
 */

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "FZZSocketIODelegate.h"
#import "FZZEventsViewController.h"
#import "FZZOverlayView.h"

@interface FZZAppDelegate : UIResponder <UIApplicationDelegate, SocketIODelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FZZEventsViewController *evc;

@property (strong, nonatomic) FZZOverlayView *navigationBar;
@property (strong, nonatomic) UITextField *searchTextField;

@property BOOL hasLoggedIn;
@property BOOL isConnecting;
@property BOOL gotAddressBook;
@property BOOL hasLoadedDataFromCache;

@property (strong, nonatomic) NSString *userPhoneNumber;

+ (BOOL)isRetinaDisplay;
- (void)setupNavigationController;
- (void)promptForLogin;
- (void)loadDataFromCache;

// Server Handlers, recieving and handing out information
- (void)updateEvents;
- (void)updateEvent:(FZZEvent *)event;


// Core Data

//@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

//
//  BCNAppDelegate.h
//  Beacon
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SocketIO.h"
#import "BCN_IOSocketDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "BCNFacebookLoginDelegate.h"
#import "BCNEventStreamViewController.h"
#import "BCNMapViewController.h"

static const UIColor *facebookColor;
static const UIColor *beaconColor;

static float const kBCNHostProfilePictureWidth = 50;
static float const kBCNHostProfilePictureHeight = 50;
static float const kBCNCommentProfilePictureWidth = 50;
static float const kBCNCommentProfilePictureHeight = 50;
static float const kBCNInviteProfilePictureWidth = 50;
static float const kBCNInviteProfilePictureHeight = 50;

@interface BCNAppDelegate : UIResponder <UIApplicationDelegate, SocketIODelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BCN_IOSocketDelegate *ioSocketDelegate;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) BCNFacebookLoginDelegate *fbLoginDelegate;
@property (strong, nonatomic) BCNEventStreamViewController *esvc;
@property (strong, nonatomic) BCNMapViewController *mvc;

+ (BOOL)isRetinaDisplay;
- (void)updateEvents:(NSArray *)events;
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;

@end

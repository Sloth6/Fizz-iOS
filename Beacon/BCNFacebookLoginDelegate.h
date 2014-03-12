//
//  BCNFacebookLoginDelegate.h
//  Beacon
//
//  Created by Andrew Sweet on 12/30/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface BCNFacebookLoginDelegate : NSObject <FBLoginViewDelegate>

-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;

@end

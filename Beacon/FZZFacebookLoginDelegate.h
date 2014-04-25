//
//  FZZFacebookLoginDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 12/30/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FZZFacebookLoginDelegate : NSObject <FBLoginViewDelegate>

-(void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error;

@end
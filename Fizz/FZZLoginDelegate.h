//
//  FZZLoginDelegate.h
//  Fizz
//
//  Created by Andrew Sweet on 7/26/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FZZLoginDelegate : NSObject

// Take the locally cached token and attempt to authenticate with the server
+(BOOL)authenticate;

@end

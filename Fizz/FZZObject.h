//
//  FZZObject.h
//  Fizz
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Fizz. All rights reserved.
//

/*
 
 Currently being used only as the ioSocketDelegate Holder, not really useful.
 
 TODO phase this object out
 
 */

#import <Foundation/Foundation.h>
#import "FZZSocketIODelegate.h"

@class FZZSocketIODelegate;

@interface FZZObject : NSObject

+ (void)setIOSocketDelegate:(FZZSocketIODelegate *)ioSocketDelegate;
+ (FZZSocketIODelegate *)getIOSocketDelegate;

@end

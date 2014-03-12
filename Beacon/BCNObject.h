//
//  BCNObject.h
//  Beacon
//
//  Created by Andrew Sweet on 12/17/13.
//  Copyright (c) 2013 Beacon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BCN_IOSocketDelegate.h"

@class BCN_IOSocketDelegate;

@interface BCNObject : NSObject

+ (void)setIOSocketDelegate:(BCN_IOSocketDelegate *)ioSocketDelegate;
+ (BCN_IOSocketDelegate *)getIOSocketDelegate;

@end

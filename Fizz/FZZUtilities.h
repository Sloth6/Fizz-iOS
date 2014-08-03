//
//  FZZUtilities.h
//  Fizz
//
//  Created by Andrew Sweet on 7/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FZZUtilities : NSObject

void runOnMainQueueWithoutDeadlocking(void (^block)(void));

@end

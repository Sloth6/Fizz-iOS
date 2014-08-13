//
//  FZZUtilities.h
//  Fizz
//
//  Created by Andrew Sweet on 7/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

static UIFont *kFZZEventFont;

@interface FZZUtilities : NSObject

void runOnMainQueueWithoutDeadlocking(void (^block)(void));
UIImage *centeredCrop(UIImage *image);
UIImage *crop(UIImage *image, CGRect rect);

@end

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
UIImage *centeredCrop(UIImage *image);
UIImage *crop(UIImage *image, CGRect rect);

UIColor *kFZZWhiteTextColor();
UIColor *kFZZGrayTextColor();

UIFont *kFZZBodyFont();
UIFont *kFZZSmallFont();
UIFont *kFZZLabelsFont();
UIFont *kFZZHostNameFont();
UIFont *kFZZHostBodyFont();
UIFont *kFZZCapsulesFont();
UIFont *kFZZInputFont();
UIFont *kFZZHeadingsFont();

//UIFont *kFZZHeadingsFontWithScale(CGFloat scale);

@end

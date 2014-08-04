//
//  FZZUtilities.m
//  Fizz
//
//  Created by Andrew Sweet on 7/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZUtilities.h"

@implementation FZZUtilities

void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

UIImage* crop(UIImage *image, CGRect rect) {
    UIGraphicsBeginImageContextWithOptions(rect.size, false, [image scale]);
    [image drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    UIImage *cropped_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cropped_image;
}

UIImage *centeredCrop(UIImage *image){
    CGFloat imageHeight = image.size.height;
    CGFloat imageWidth  = image.size.width;
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat screenHeight = screenRect.size.height * 2;
    CGFloat screenWidth  = screenRect.size.width * 2;
    
    screenRect.origin.y = (imageHeight/2) - (screenHeight/2);
    screenRect.origin.x = (imageWidth/2) - (screenWidth/2);
    
    return crop(image, screenRect);
}

@end

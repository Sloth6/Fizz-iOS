//
//  FZZDefaultBubble.h
//  Fizz
//
//  Created by Andrew Sweet on 3/26/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

/*
 
 This is used when you try to get an image from a FZZUser object. This allows the image to be scaled and cropped into a circle. The UIImage returned from imageFromBubble would not be cropped.
 
 */

#import <UIKit/UIKit.h>

@interface FZZDefaultBubble : UIView

- (UIImage *)imageFromBubble;
    
@end

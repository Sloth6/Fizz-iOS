//
//  FZZParallaxCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/24/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZParallaxCell : UITableViewCell

@property (strong, nonatomic) UITextView *textView;

-(void)setProgress:(float)progress;
+(float)parallaxOffset;

@end

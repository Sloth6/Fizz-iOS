//
//  FZZTestViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/11/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FZZTestViewController : UIViewController

@property IBOutlet UITextView *textView;
@property IBOutlet UITextView *placeholderTV;

-(void)setFont:(UIFont *)font;

@end

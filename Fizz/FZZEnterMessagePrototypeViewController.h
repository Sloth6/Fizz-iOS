//
//  FZZEnterMessagePrototypeViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/11/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 This view controller and its NIB define the dimensions of the chatbox
 users enter text into for the chat thread. The NIB is used to define
 constraints visually, as it would be tedious to do so otherwise.
 
 */

@interface FZZEnterMessagePrototypeViewController : UIViewController

@property IBOutlet UITextView *textView;
@property IBOutlet UITextView *placeholderTV;

-(void)setFont:(UIFont *)font;

@end

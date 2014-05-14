//
//  FZZBackspaceResignTextField.h
//  Fizz
//
//  Created by Andrew Sweet on 3/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 This is a custom textField which allows hitting backspace on an empty textfield to act as a dismissal tool for the keyboard. It's pretty non-standard as far as Apple standards go, and was designed because we didn't have a specific UI element for dismissing the keyboard. Most keyboards are now dismissed by the navigation button turning into an X. Useful class if neccessary.
 
 */

@interface FZZBackspaceResignTextField : UITextField

@end

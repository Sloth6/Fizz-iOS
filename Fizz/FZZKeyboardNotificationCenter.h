//
//  FZZKeyboardNotificationCenter.h
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FZZKeyboardManagedObject <UITextInputDelegate>

-(void)keyboardWillShow:(NSNotification *)note;
-(void)keyboardWillHide:(NSNotification *)note;

@end

@interface FZZKeyboardNotificationCenter : NSObject

+ (void)updateFirstResponderAsTextInputDelegate:(id<FZZKeyboardManagedObject>)textInputDelegate;

@end

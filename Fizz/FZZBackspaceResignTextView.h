//
//  FZZBackspaceResignTextView.h
//  Fizz
//
//  Created by Andrew Sweet on 3/19/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 This is a custom textView (ie multiline textField) which allows hitting backspace on an empty textView to act as a dismissal tool for the keyboard. It's pretty non-standard as far as Apple standards go, and was designed because we didn't have a specific UI element for dismissing the keyboard. Most keyboards are now dismissed by the navigation button turning into an X. Useful class if neccessary.
 
 */

@class FZZEventsExpandedViewController;

@interface FZZBackspaceResignTextView : UIView

-(UITextView *)textView;

-(void)setESVC:(FZZEventsExpandedViewController *)esvc;
-(void)setPlaceholderText:(NSString *)placeholderText;

-(NSTextContainer *)textContainer;
-(void)setFrame:(CGRect)frame;
-(void)setText:(NSString *)text;
-(void)deleteBackward;

-(void)setFont:(UIFont *)font;
-(void)setEditable:(BOOL)editable;
-(void)setScrollEnabled:(BOOL)scrollEnabled;

-(void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically;
-(void)setReturnKeyType:(UIReturnKeyType)returnKeyType;

-(void)setDelegate:(id<UITextViewDelegate>)delegate;
-(BOOL)resignFirstResponder;

- (void)myTextDidChange;

/*
 [_textView textContainer].maximumNumberOfLines = 3;
 [_textView setFrame:CGRectMake(x, y, width, height)];
 [_textView setText:@""];
 [_textView deleteBackward];
 [_textView setBackgroundColor:[UIColor clearColor]];
 
 
 [cell.textView setDelegate:self];
 
 [_textView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:38]];
 [_textView setEditable:NO];
 [_textView setScrollEnabled:NO];
 [_textView setUserInteractionEnabled:NO];
 [_textView setBackgroundColor:[UIColor clearColor]];
 
 */

@end

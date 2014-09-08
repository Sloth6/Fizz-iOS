//
//  FZZInputVerificationCodeViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 7/26/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

@interface FZZInputVerificationCodeViewController : UIViewController <UITextFieldDelegate>

//@property IBOutlet UIButton *test;
@property IBOutlet UILabel *label;

- (void)setKeyboardHeight:(CGFloat)keyboardHeight;

- (void)textFieldBecomeFirstResponder;

- (void)sendCode:(NSString *)code;
- (void)failVerificationStep;

@end

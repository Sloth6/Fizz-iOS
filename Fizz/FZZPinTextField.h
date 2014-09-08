//
//  FZZPinTextField.h
//  Fizz
//
//  Created by Andrew Sweet on 8/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZInputVerificationCodeViewController;

@interface FZZPinTextField : UIView <UITextFieldDelegate>

- (id)initWithFrame:(CGRect)frame andNumberOfCharacters:(NSInteger)numberOfCharacters;

- (void)setIVCVC:(FZZInputVerificationCodeViewController *)ivcvc;

- (void)clearText;

@end

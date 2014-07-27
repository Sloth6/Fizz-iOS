//
//  FZZInputVerificationCodeViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 7/26/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "ViewController.h"

@interface FZZInputVerificationCodeViewController : UIViewController <UITextFieldDelegate>

@property IBOutlet UITextField *verificationCodeField;

//@property IBOutlet UIButton *test;
@property IBOutlet UIButton *confirmCodeButton;

- (IBAction)verifyButtonHit:(id)sender;

@end

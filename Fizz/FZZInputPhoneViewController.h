//
//  FZZInputPhoneViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 This is where the user inputs his/her phone number for the first time on login. Visuals are defined in the NIB for ease.
 
 */

@interface FZZInputPhoneViewController : UIViewController <UITextFieldDelegate>

@property IBOutlet UITextField *textField;

//@property IBOutlet UIButton *test;
@property IBOutlet UIButton *confirmPhoneButton;

- (IBAction)savePhoneNumber:(id)sender;

@end

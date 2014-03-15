//
//  BCNInputPhoneViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCNInputPhoneViewController : UIViewController <UITextFieldDelegate>

@property IBOutlet UITextField *textField;
@property IBOutlet UIButton *confirmPhoneButton;

- (IBAction)savePhoneNumber:(id)sender;

@end

//
//  BCNInviteViewController.h
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCNInviteViewController : UITableViewController <UITextFieldDelegate>

@property UILabel *label;
@property UITextView *textView;
@property UISwitch *toggleSecret;
@property UITextField *phoneTextField;
@property UIButton *confirmPhoneButton;

@end

//
//  FZZInputPhoneTableViewCell.h
//  Fizz
//
//  Created by Andrew Sweet on 8/27/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZUnderlinedTextField;

@interface FZZInputPhoneTableViewCell : UITableViewCell

@property IBOutlet FZZUnderlinedTextField *firstNameTextField;
@property IBOutlet FZZUnderlinedTextField *lastNameTextField;
@property IBOutlet FZZUnderlinedTextField *cellPhoneTextField;

@property IBOutlet UILabel *infoLabel;

- (void)formatText;

@end

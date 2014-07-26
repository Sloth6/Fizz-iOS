//
//  FZZDetailTextCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/9/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 
 This TableViewCell appears in the chat thread. 
 
 It contains the face of the user who said the message (profileImageView),
 as well as the text (label).
 
 */

@interface FZZUserMessageCell : UITableViewCell

@property IBOutlet UILabel *label;

+ (CGSize)getTextBoxForText:(NSString *)text withLabelWidth:(float)labelWidth;

@end

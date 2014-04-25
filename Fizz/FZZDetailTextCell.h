//
//  FZZDetailTextCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/9/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZDetailTextCell : UITableViewCell

@property IBOutlet UILabel *label;
@property IBOutlet UIImageView *profileImageView;

+ (CGSize)getTextBoxForText:(NSString *)text withLabelWidth:(float)labelWidth;

@end

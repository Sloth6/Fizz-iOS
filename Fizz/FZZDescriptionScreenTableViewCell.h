//
//  FZZDescriptionScreenTableViewCell.h
//  Fizz
//
//  Created by Andrew Sweet on 8/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZZTableViewCell.h"

@interface FZZDescriptionScreenTableViewCell : FZZTableViewCell <UIActionSheetDelegate, UIAlertViewDelegate>

@property UITextView *textView;

//-(void)setText:(NSString *)text;
-(void)setEventIndexPath:(NSIndexPath *)indexPath;

@end

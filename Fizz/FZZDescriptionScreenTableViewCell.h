//
//  FZZDescriptionScreenTableViewCell.h
//  Fizz
//
//  Created by Andrew Sweet on 8/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZDescriptionScreenTableViewCell : UITableViewCell

@property IBOutlet UITextView *textView;

//-(void)setText:(NSString *)text;
-(void)setEventIndexPath:(NSIndexPath *)indexPath;

@end

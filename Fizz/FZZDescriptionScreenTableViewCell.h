//
//  FZZDescriptionScreenTableViewCell.h
//  Fizz
//
//  Created by Andrew Sweet on 8/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FZZExpandedVerticalTableViewController;

@interface FZZDescriptionScreenTableViewCell : UITableViewCell <NSLayoutManagerDelegate, UITextViewDelegate>

@property UITextView *textView;


//-(void)setText:(NSString *)text;
-(void)setEventIndexPath:(NSIndexPath *)indexPath;

-(void)setTableViewController:(FZZExpandedVerticalTableViewController *)evtvc;
-(void)handleAnimationsOnScroll:(CGFloat)alpha;

@end

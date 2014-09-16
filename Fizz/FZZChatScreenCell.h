//
//  FZZChatScreenCell.h
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZZKeyboardNotificationCenter.h"
#import "FZZTableViewCell.h"

@class FZZEvent;

@interface FZZChatScreenCell : FZZTableViewCell <UITextViewDelegate, FZZKeyboardManagedObject>

@property (nonatomic, retain) UIView *viewForm;
@property (nonatomic, retain) UITextView *chatBox;

-(void)setEventIndexPath:(NSIndexPath *)indexPath;
-(void)updateMessages;

-(UIScrollView *)scrollView;

@end

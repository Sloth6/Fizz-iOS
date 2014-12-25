//
//  FZZUserMessageCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/9/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FZZMessage;

/*
 
 This TableViewCell appears in the chat thread. 
 
 It contains the face of the user who said the message (profileImageView),
 as well as the text (label).
 
 */

@interface FZZUserMessageCell : UITableViewCell

@property IBOutlet UILabel *messageLabel;
@property IBOutlet UILabel *userLabel;

+ (CGSize)getTextBoxForMessage:(FZZMessage *)message withLabelWidth:(float)labelWidth;

+ (float)messageLabelWidth;

- (void)setMessageText:(NSString *)text isMe:(BOOL)isUserMe;
- (void)setUserName:(NSString *)text isMe:(BOOL)isUserMe;

@end

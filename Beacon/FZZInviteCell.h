//
//  FZZInviteCell.h
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZZInviteCell : UITableViewCell

@property IBOutlet UIImageView *imageView;
@property IBOutlet UILabel *label;

- (void)setIsSelected:(BOOL)selection;
- (BOOL)isSelected;

- (void)setHasFriend:(BOOL)hasFriend;
- (BOOL)hasFriend;

@end

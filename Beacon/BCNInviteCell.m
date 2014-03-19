//
//  BCNInviteCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNInviteCell.h"

@interface BCNInviteCell ()

@property BOOL isSelected;

@end

@implementation BCNInviteCell

@synthesize isSelected;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        isSelected = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIsSelected:(BOOL)selection{
    isSelected = selection;
    
    if (isSelected) {
        _label.textColor = [UIColor lightGrayColor];
    } else {
        _label.textColor = [UIColor blackColor];
    }
}

- (BOOL)isSelected{
    return isSelected;
}

@end

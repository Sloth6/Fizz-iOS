//
//  FZZContactTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZContactTableViewCell.h"

#import "FZZUtilities.h"

@interface FZZContactTableViewCell ()

@end

@implementation FZZContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self setupTextLabel];
    }
    return self;
}

- (void)setupTextLabel{
    UIFont *font = kFZZInputFont();
    
    [[self textLabel] setFont:font];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (self.isSelected) {
        [[self textLabel] setTextColor:kFZZWhiteTextColor()];
    } else {
        [[self textLabel] setTextColor:kFZZGrayTextColor()];
    }
}

@end

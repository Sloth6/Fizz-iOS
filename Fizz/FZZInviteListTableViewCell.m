//
//  FZZInviteListTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInviteListTableViewCell.h"

@implementation FZZInviteListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self setupLabel];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setOpaque:NO];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setupLabel{
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:20];
    
    [[self textLabel] setFont:font];
    [[self textLabel] setTextColor:[UIColor whiteColor]];
}

- (void)setIsGoing:(BOOL)isGoing{
    if (isGoing){
        [[self textLabel] setTextColor:[UIColor whiteColor]];
    } else {
        [[self textLabel] setTextColor:[UIColor grayColor]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

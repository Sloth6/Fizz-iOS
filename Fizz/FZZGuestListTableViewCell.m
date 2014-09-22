//
//  FZZGuestListTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZGuestListTableViewCell.h"
#import "FZZUtilities.h"

@implementation FZZGuestListTableViewCell

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
    UIFont *font = kFZZSmallFont();
    
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    
    [_label setFont:font];
    [_label setTextColor:kFZZWhiteTextColor()];
    
    CGFloat dx = kFZZHorizontalMargin();
    CGFloat dy = -15;
    
    CGRect frame = self.bounds;
    frame.origin.x += dx;
    frame.origin.y += dy;
    frame.size.width -= dx;
    
    [_label setFrame:frame];
    [[self contentView] addSubview:_label];
}

- (void)setIsGoing:(BOOL)isGoing{
    if (isGoing){
        [_label setTextColor:kFZZWhiteTextColor()];
    } else {
        [_label setTextColor:kFZZGrayTextColor()];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

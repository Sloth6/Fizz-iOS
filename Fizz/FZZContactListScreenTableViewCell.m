//
//  FZZContactListScreenTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/14/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZContactListScreenTableViewCell.h"

@interface FZZContactListScreenTableViewCell ()

@property (strong, nonatomic)  NSIndexPath *eventIndexPath;

@end

@implementation FZZContactListScreenTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setEventIndexPath:(NSIndexPath *)indexPath{
    _eventIndexPath = indexPath;
}

@end

//
//  FZZDescriptionScreenTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/7/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZDescriptionScreenTableViewCell.h"
#import "FZZEvent.h"

@interface FZZDescriptionScreenTableViewCell ()



@end

@implementation FZZDescriptionScreenTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
    FZZEvent *event = [FZZEvent getEventAtIndexPath:indexPath];
    NSString *title = [event eventDescription];
    
    [_textView setText:title];
    NSLog(@"event: <%@>", title);
    [_textView setNeedsDisplay];
}

@end

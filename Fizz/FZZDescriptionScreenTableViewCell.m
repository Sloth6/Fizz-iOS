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
        [self setupBackground];
        [self setupTextview];
    }
    return self;
}

- (void)setupBackground{
    [self setBackgroundColor:[UIColor clearColor]];
    [self setOpaque:NO];
}

- (void)setupTextview{
    CGFloat leftBorder   = 4;
    CGFloat topBorder    = 50;
    CGFloat rightBorder  = 4;
    CGFloat bottomBorder = 4;
    
    CGRect frame = [UIScreen mainScreen].bounds;
    
    frame.origin.x += leftBorder;
    frame.origin.y += topBorder;
    frame.size.width  -= (leftBorder + rightBorder);
    frame.size.height -= (topBorder + bottomBorder);
    
    _textView = [[UITextView alloc] initWithFrame:frame];
    [self addSubview:_textView];
    
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView setOpaque:NO];
    [_textView setUserInteractionEnabled:NO];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:50.0];
    
    [_textView setFont:font];
    [_textView setTextColor:[UIColor whiteColor]];
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

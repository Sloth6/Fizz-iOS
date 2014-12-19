//
//  FZZEventMainCell.m
//  Fizz
//
//  Created by Andrew Sweet on 7/30/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZEventMainCell.h"
#import "FZZUtilities.h"

@interface FZZEventMainCell ()

@property UITextView *textView;

@end

@implementation FZZEventMainCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self setupTextView];
        [self setupShakeScreenText];
    }
    return self;
}

- (void)setupTextView{
    CGRect frame = [UIScreen mainScreen].bounds;
    
    _textView = [[UITextView alloc] initWithFrame:frame];
    [_textView setEditable:NO];
    [_textView setScrollEnabled:NO];
    
    UIFont *font = kFZZHeadingsFont();//[UIFont fontWithName:@"Futura-Medium" size:20.0];
    
    [_textView setText:@""];
    
    [_textView setFont:font];
    [_textView setTextColor:kFZZWhiteTextColor()];
    
    [self addSubview:_textView];
}

- (void)setupShakeScreenText{
    return;
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

@end

//
//  FZZInputPhoneTableViewCell.m
//  Fizz
//
//  Created by Andrew Sweet on 8/27/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInputPhoneTableViewCell.h"

#import "FZZUtilities.h"
#import "FZZUnderlinedTextField.h"

@implementation FZZInputPhoneTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)formatText{
    [self formatInfoLabel];
    
    [self formatTextField:_firstNameTextField];
    [self formatTextField:_lastNameTextField];
    [self formatTextField:_cellPhoneTextField];
}

- (void)formatInfoLabel{
    [_infoLabel setFont:kFZZInputFont()];
    [_infoLabel setTextColor:kFZZWhiteTextColor()];
    
    CGRect bounds = [_infoLabel bounds];
    
    CGFloat y = bounds.origin.y;
    CGFloat height = bounds.size.height;
    
    [_infoLabel sizeToFit];
    
    CGRect updatedBounds = [_infoLabel bounds];
    
    CGFloat updatedHeight = updatedBounds.size.height;
    CGFloat dy = height - updatedHeight;
    y += dy;
    
    updatedBounds.origin.y = y;
    
    [_infoLabel setBounds:updatedBounds];
}

- (void)formatTextField:(FZZUnderlinedTextField *)textField{
    [textField setPlaceholderTextColor:kFZZGrayTextColor()];
    [textField setFont:kFZZInputFont()];
    [textField setTextColor:kFZZWhiteTextColor()];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
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

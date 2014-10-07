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

@property BOOL wasSelected;
@property (nonatomic) UITableViewController *tvc;
@property (nonatomic) NSIndexPath *indexPath;

@end

@implementation FZZContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self setupTextLabel];
        
        _wasSelected = NO;
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

- (void)handleTextColor{
    if (_wasSelected) {
        [[self textLabel] setTextColor:kFZZWhiteTextColor()];
    } else {
        [[self textLabel] setTextColor:kFZZGrayTextColor()];
    }
}

- (void)hitCell{
    [_tvc tableView:[_tvc tableView] didSelectRowAtIndexPath:_indexPath];
}

- (void)toggleSelected{
    _wasSelected = !_wasSelected;
    
    [self handleTextColor];
}

- (void)setSelectionState:(BOOL)isSelected{
    _wasSelected = isSelected;
    
    [self handleTextColor];
}

@end

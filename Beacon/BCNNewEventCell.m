//
//  BCNNewEventCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNNewEventCell.h"
#import "BCNInviteViewController.h"

@implementation BCNNewEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setupTableview];
        
        [self setupTextView];
        
        [self setupToggle];
    }
    return self;
}

- (void)setupTableview{
    _ivc = [[BCNInviteViewController alloc] init];
    [_ivc.tableView setFrame:self.frame];
    [_ivc.tableView setScrollEnabled:NO];
    
    [self.contentView addSubview:_ivc.tableView];
}

- (void)setupToggle{
    float y = _textView.frame.origin.y + _textView.frame.size.height;
    float endX = _textView.frame.origin.x + _textView.frame.size.width;
    
    float ySpace = 5;
    float xSpace = 10;
    
    float xSwitchMargin = 0;
    
    float switchWidth  = 49;
    float switchHeight = 31;
    float switchX = endX - switchWidth - xSwitchMargin;
    float switchY = y + ySpace;
    
    CGRect switchRect = CGRectMake(switchX, switchY, switchWidth, switchHeight);
    
    
    float labelX = _textView.frame.origin.x;
    float labelWidth = switchX - labelX - xSpace;
    float labelY = switchY;
    float labelHeight = switchHeight;
    
    CGRect labelRect = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    
    _toggleSecret = [[UISwitch alloc] initWithFrame:switchRect];
    _label = [[UILabel alloc] initWithFrame:labelRect];
    
    [_label setTextAlignment:NSTextAlignmentRight];
    [_label setText:@"Secret Event"];
    
    [self.contentView addSubview:_toggleSecret];
    [self.contentView addSubview:_label];
}

- (void)setupTextView{
    // Hard coded value, should be fine for these purposes
    float keyboardHeight = 216;
    
    float hInset  = 20;
    float hOutset = hInset;
    float vInset  = 60;
    float vOutset = 50 + keyboardHeight;
    
    float sWidth  = [UIScreen mainScreen].bounds.size.width;
    float sHeight = [UIScreen mainScreen].bounds.size.height;
    
    float x = hInset;
    float width = sWidth - x - hOutset;
    
    float y = vInset;
    float height = sHeight - y - vOutset;
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    
    [self.contentView addSubview:_textView];
    
    _textView.enablesReturnKeyAutomatically = YES;
    [_textView setReturnKeyType:UIReturnKeySend];
    [_textView setFont:[UIFont fontWithName:@"HelveticaNeue" size:26]];
    [_textView setTextColor:[UIColor lightGrayColor]];
    
    [_textView setScrollEnabled:NO];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

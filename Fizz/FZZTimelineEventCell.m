//
//  FZZTimelineEventCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/19/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZTimelineEventCell.h"
#import "FZZInviteViewController.h"

@implementation FZZTimelineEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupTextView];
        
        [self setupTableview];
    }
    return self;
}

- (void)setupTableview{
    _ivc = [[FZZInviteViewController alloc] init];
    
    [_ivc updateFriends];
    
    _ivc.textView = _textView;
    
    [_ivc.tableView setFrame:self.frame];
    [_ivc.tableView setScrollEnabled:NO];
    
    [self.contentView addSubview:_ivc.tableView];
}

- (void)sendInvitations{
    [_ivc sendInvitations];
}

- (void)setScrollingEnabled:(BOOL)canScroll{
    [_ivc.tableView setScrollEnabled:canScroll];
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

    [_textView setFont:[UIFont fontWithName:@"Helvetica Neue" size:38]];
    [_textView setEditable:NO];
    
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

//
//  FZZExpandedNewEventCell.m
//  Fizz
//
//  Created by Andrew Sweet on 3/15/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZExpandedNewEventCell.h"
#import "FZZInviteViewController.h"
#import "FZZAppDelegate.h"
#import "FZZChatDelegate.h"

#import "FZZBackspaceResignTextView.h"

@interface FZZExpandedNewEventCell ()

@property (strong, nonatomic) UIButton *sendInviteButton;
@property BOOL isSetup;

@end

@implementation FZZExpandedNewEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _isSetup = NO;
        
        [self setupNewEventTextView];
    }
    return self;
}

- (void)setupNewEventTextView{
    
    if (!_isSetup){
        _isSetup = YES;
        
        // Hard coded value, should be fine for these purposes
        float keyboardHeight = 216;
        
        float hInset  = 50;
        float hOutset = hInset;
        float vInset  = 60;
        float vOutset = 50 + keyboardHeight;
        
        float sWidth  = [UIScreen mainScreen].bounds.size.width;
        float sHeight = [UIScreen mainScreen].bounds.size.height;
        
        float x = hInset;
        float width = sWidth - x - hOutset;
        
        float y = vInset;
        float height = sHeight - y - vOutset;
        
        _resignTextViewer = [[FZZBackspaceResignTextView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        
        [_resignTextViewer setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:38]];
        
        [self addSubview:_resignTextViewer];
        
        [_resignTextViewer textContainer].maximumNumberOfLines = 3;
        
        [_resignTextViewer setBackgroundColor:[UIColor clearColor]];
    }
    
    [_resignTextViewer setEditable:NO];
    [_resignTextViewer setScrollEnabled:NO];
    [_resignTextViewer setUserInteractionEnabled:NO];
    [_resignTextViewer setBackgroundColor:[UIColor clearColor]];
    
    // Enable the placeholder text
    [_resignTextViewer setText:@""];
    [_resignTextViewer deleteBackward];
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

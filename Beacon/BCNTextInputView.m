//
//  BCNTextInputView.m
//  Beacon
//
//  Created by Andrew Sweet on 3/10/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNTextInputView.h"

@implementation BCNTextInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        float width   = [UIScreen mainScreen].bounds.size.width;
//        float buffer  = 7.0;
//        float vBuffer = 3.0;
//        
//        float x = buffer;
//        float height = 30.0;
//        
//        CGRect leftButtonFrame = CGRectMake(x, vBuffer, height, height);
//        
//        x += leftButtonFrame.size.width + buffer;
//        
//        float rButtonWidth = height;
//        
//        float rX = width - (rButtonWidth + buffer);
//        
//        CGRect rightButtonFrame = CGRectMake(rX, vBuffer, rButtonWidth, height);
//        
//        float textFrameWidth = (rX - buffer) - x;
//        
//        CGRect textFrame = CGRectMake(x, vBuffer, textFrameWidth, height);
        
        // Initialization code
        _textView    = [[UITextView alloc] init];
        _rightButton = [[UIButton   alloc] init];
        _leftButton  = [[UIButton   alloc] init];
        
        [self addSubview:_textView];
        [self addSubview:_rightButton];
        [self addSubview:_leftButton];
        
        
//        // Horizontal layout - note the options for aligning the top and bottom of all views
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_leftButton(30)]-[_textView]-[_rightButton(30)]-|" options: NSLayoutFormatAlignAllBottom metrics:nil views:NSDictionaryOfVariableBindings(_leftButton, _rightButton, _textView)]];
//        
//        // Vertical layout - we only need one "column" of information because of the alignment options used when creating the horizontal layout
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_leftButton(30)]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_leftButton)]];
//
//        [self addConstraints:[NSLayoutConstraint
//                                   constraintsWithVisualFormat:@"V:[_leftButton(==_rightButton)]-3-|"
//                                   options:NSLayoutFormatAlignAllBottom
//                                   metrics:nil
//                                   views:NSDictionaryOfVariableBindings(_leftButton, _rightButton)]];
//
//        [self addConstraints:[NSLayoutConstraint
//                              constraintsWithVisualFormat:@"V:[_rightButton(30)]"
//                              options:NSLayoutFormatDirectionLeadingToTrailing
//                              metrics:nil
//                              views:NSDictionaryOfVariableBindings(_rightButton)]];
//        
//        [self addConstraints:[NSLayoutConstraint
//                              constraintsWithVisualFormat:@"V:|-3-[_textView]-3-|"
//                              options:NSLayoutFormatAlignAllBottom
//                              metrics:nil
//                              views:NSDictionaryOfVariableBindings(_textView)]];
//
//        [self addConstraints:[NSLayoutConstraint
//                              constraintsWithVisualFormat:@"[_leftButton(30)]"
//                              options:NSLayoutFormatDirectionLeadingToTrailing
//                              metrics:nil
//                              views:NSDictionaryOfVariableBindings(_leftButton)]];
//        
//        [self addConstraints:[NSLayoutConstraint
//                            constraintsWithVisualFormat:@"[_rightButton(30)]"
//                              options:NSLayoutFormatDirectionLeadingToTrailing
//                              metrics:nil
//                              views:NSDictionaryOfVariableBindings(_rightButton)]];
        
//        [self addConstraints:[NSLayoutConstraint
//                              constraintsWithVisualFormat:@"|-7-[_leftButton(30)]-7-[_textView]-7-[_rightButton(30)]-7-|"
//                              options:NSLayoutFormatAlignAllBottom
//                              metrics:nil
//                              views:NSDictionaryOfVariableBindings(_leftButton, _textView, _rightButton)]];
    }
    
    return self;
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

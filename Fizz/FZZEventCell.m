//
//  FZZEventCell.m
//  Fizz
//
//  Created by Andrew Sweet on 1/17/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZEventCell.h"
#import "FZZEvent.h"
#import "FZZMessage.h"
#import "FZZUser.h"

@implementation FZZEventCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        _textView.autoresizingMask = UIViewAutoresizingNone;
        _textView.contentMode = UIViewContentModeScaleToFill;
        _textView.userInteractionEnabled = NO;
        _textView.textAlignment = NSTextAlignmentNatural;
        
        [self.contentView addSubview:_textView];
    }
    return self;
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGRect textViewFrame = CGRectMake(0,0, frame.size.width, frame.size.height);
    
    [_textView setFrame:textViewFrame];
    [_textView setNeedsDisplay];
    [self setNeedsDisplay]; // force drawRect:
}

-(void)setEventCollapsed:(FZZEvent *)event{
    if (event == NULL){
        [_textView setText:@"Create A New Event"];
        
        return;
    }
    
    // Text
    NSString *text = [event eventDescription];
    
    [_textView setText:text];
}

- (void)setEvent:(FZZEvent *)event {
    // Text
    NSString *text = [event eventDescription];
    
    [_textView setText:text];
    [self.contentView setNeedsDisplay];
}

@end

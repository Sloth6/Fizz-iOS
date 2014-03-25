//
//  BCNBackspaceResignTextView.m
//  Fizz
//
//  Created by Andrew Sweet on 3/19/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNBackspaceResignTextView.h"
#import "BCNEventStreamViewController.h"

static NSString *kBCNPlaceholderText = @"What do you want to do?";

@interface BCNBackspaceResignTextView ()

@property BCNEventStreamViewController *esvc;

@end

@implementation BCNBackspaceResignTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)deleteBackward
{
    [super deleteBackward];
    
    if ([self.text isEqualToString:@""]){
        if (_esvc != NULL){
            // Resign first responder status, update interface
            [_esvc exitNewEventPrompt:self];
        } else {
            [self resignFirstResponder];
        }
    }
}

-(void)setESVC:(BCNEventStreamViewController *)esvc{
    _esvc = esvc;
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

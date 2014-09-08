//
//  FZZPinNumberLabel.m
//  Fizz
//
//  Created by Andrew Sweet on 8/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZPinNumberLabel.h"
#import "FZZPinDotView.h"

#import "FZZUtilities.h"

@interface FZZPinNumberLabel ()

@property UIView *dot;

@end

@implementation FZZPinNumberLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        frame.origin.x = 0;
        frame.origin.y = 0;
        
        _label = [[UILabel alloc] initWithFrame:frame];
        [_label setFont:kFZZPinInputFont()];
        [_label setTextColor:kFZZWhiteTextColor()];
        [self addSubview:_label];
        
        _dot = [[FZZPinDotView alloc] initWithFrame:frame];
        [self addSubview:_dot];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    [_label setFrame:frame];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//    if ([_symbol isEqual:@""]){
//        [super drawRect:rect];
//    } else {
//        [self drawDot];
//    }
//}

- (void)setSymbol:(NSString *)symbol{
    if ([symbol isEqual:@""]){
        [_label setHidden:YES];
        [_dot setHidden:NO];
    } else {
        [_label setHidden:NO];
        [_dot setHidden:YES];
    }
    
    [_label setText:symbol];
}

@end

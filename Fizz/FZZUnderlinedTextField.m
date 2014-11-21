//
//  FZZUnderlinedTextField.m
//  Fizz
//
//  Created by Andrew Sweet on 8/29/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZUnderlinedTextField.h"
#import "FZZUtilities.h"

@implementation FZZUnderlinedTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 0, kFZZTextInputBottomPadding() - 4 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 0 , kFZZTextInputBottomPadding() - 4 );
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds{
    return CGRectInset( bounds , 0 , kFZZTextInputBottomPadding() - 4 );
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Drawing code
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGRect bounds = self.bounds;
    
    CGFloat x1 = 0;
    CGFloat x2 = bounds.size.width - bounds.origin.x;
    CGFloat y = bounds.size.height - bounds.origin.y - 1;
    
    CGFloat gray[4] = {1.0f, 1.0f, 1.0f, 0.5f};
    
    CGContextSetStrokeColor(c, gray);
    CGContextSetLineWidth(c, 1.0);
    CGContextBeginPath(c);
    
    CGContextMoveToPoint(c, x1, y);
    CGContextAddLineToPoint(c, x2, y);
    CGContextStrokePath(c);
}


@end

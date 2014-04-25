//
//  FZZMessageTextView.m
//  Fizz
//
//  Created by Andrew Sweet on 3/11/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZMessageTextView.h"

@implementation FZZMessageTextView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    int numLines = round(self.contentSize.height / self.font.lineHeight);
    
    if (numLines >= 5)
        [super scrollRectToVisible: rect animated: animated];
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

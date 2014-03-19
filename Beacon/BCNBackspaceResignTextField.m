//
//  BCNBackspaceResignTextField.m
//  Fizz
//
//  Created by Andrew Sweet on 3/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "BCNBackspaceResignTextField.h"

@implementation BCNBackspaceResignTextField

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
        [self resignFirstResponder];
    }
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

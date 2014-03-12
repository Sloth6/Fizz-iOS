//
//  BCNDetailTextCell.m
//  Beacon
//
//  Created by Andrew Sweet on 3/9/14.
//  Copyright (c) 2014 Beacon. All rights reserved.
//

#import "BCNDetailTextCell.h"

@implementation BCNDetailTextCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIFont *font = [UIFont systemFontOfSize:16.0];
        
        [_label setFont:font];
    }
    return self;
}

+ (CGSize)getTextBoxForText:(NSString *)text withLabelWidth:(float)textWidth
{
    //CGFloat textWidth = [UIScreen mainScreen].bounds.size.width - (52 + (7 * 3) + 47);
    
    UIFont *font = [UIFont systemFontOfSize:16.0];
    
    CGFloat width = textWidth;
    NSAttributedString *attributedText =
    [[NSAttributedString alloc]
     initWithString:text
     attributes:@
     {
     NSFontAttributeName: font
     }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){width, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    return rect.size;
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

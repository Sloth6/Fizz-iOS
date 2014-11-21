//
//  FZZCustomPlaceholderTextField.m
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZCustomPlaceholderTextField.h"

@interface FZZCustomPlaceholderTextField ()

@property UIColor *placeholderColor;

@end

@implementation FZZCustomPlaceholderTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setAdjustsFontSizeToFitWidth:YES];
    }
    return self;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderColor{
    _placeholderColor = placeholderColor;
}

+ (CGRect)getDrawRectForText:(NSString *)text
              withAttributes:(NSDictionary *)attributes inRect:(CGRect)rect
{
    CGSize size = [text sizeWithAttributes:attributes];
    
    CGFloat textHeight = size.height;
    
    CGFloat rectHeight = rect.size.height;
    
    NSLog(@"rectHeight = %f textHeight = %f", rectHeight, textHeight);
    
    CGFloat y = (rectHeight/2.0) - (textHeight/2.0);
    CGFloat x = rect.origin.x;
    CGFloat width = size.width;
    
    return CGRectMake(x, y, width, textHeight);
}

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 5 , 5 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 5 , 5 );
}

-(CGFloat)textInset{
    return 0;//2;
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    if (_placeholderColor){
        [_placeholderColor setFill];
        
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textStyle.alignment = NSTextAlignmentLeft;
        
        
        NSDictionary *attributes = @{ NSFontAttributeName: self.font,
                                      NSParagraphStyleAttributeName: textStyle,
                                      NSForegroundColorAttributeName: self.placeholderColor};
        
        CGRect textRect = [FZZCustomPlaceholderTextField getDrawRectForText:[self placeholder]
                                                             withAttributes:attributes
                                                                     inRect:rect];
        
        NSLog(@"orig: %@ textRect:%@", NSStringFromCGRect(rect), NSStringFromCGRect(textRect));
        
        [[self placeholder] drawInRect:textRect withAttributes:attributes];
        
        return;
    }
    
    // If all else fails, draw normally
    [super drawPlaceholderInRect:rect];
}

- (void)drawTextInRect:(CGRect)rect{
    [self.textColor setFill];
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{ NSFontAttributeName: self.font,
                                  NSParagraphStyleAttributeName: textStyle,
                                  NSForegroundColorAttributeName: self.textColor};
    
    CGRect textRect = [FZZCustomPlaceholderTextField getDrawRectForText:[self placeholder]
                                                         withAttributes:attributes
                                                                 inRect:rect];
    
    [[self text] drawInRect:textRect withAttributes:attributes];
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

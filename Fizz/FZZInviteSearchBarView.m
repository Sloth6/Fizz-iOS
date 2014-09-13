//
//  FZZInviteSearchBarView.m
//  Fizz
//
//  Created by Andrew Sweet on 8/18/14.
//  Copyright (c) 2014 Fizz. All rights reserved.
//

#import "FZZInviteSearchBarView.h"
#import "FZZCustomPlaceholderTextField.h"
#import "FZZUtilities.h"

@interface FZZInviteSearchBarView ()

@property (nonatomic) BOOL shouldDrawLine;

@property (strong, nonatomic) FZZCustomPlaceholderTextField *textField;

@end

@implementation FZZInviteSearchBarView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self){
        // Initialization code
        [self setupSearchBar];
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _shouldDrawLine = NO;
    }
    
    return self;
}

-(void)setShouldDrawLine:(BOOL)shouldDrawLine{
    if (_shouldDrawLine != shouldDrawLine){
        _shouldDrawLine = shouldDrawLine;
        [self setNeedsDisplay];
    }
}

- (void)setupSearchBar{
    [_textField removeFromSuperview];
    
    _textField = [[FZZCustomPlaceholderTextField alloc] initWithFrame:self.bounds];
    
    UIFont *font = kFZZInputFont();
    
    [_textField setFont:font];
    
    [_textField setTextColor:kFZZWhiteTextColor()];
    [_textField setPlaceholderTextColor:kFZZGrayTextColor()];
    
    NSString *placeholder = @"search for a friend to invite";
    
    [_textField setPlaceholder:placeholder];
    [_textField setText:placeholder];
    
    [_textField setEnabled:NO];
    [_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    [_textField setKeyboardAppearance:UIKeyboardAppearanceDark];
    [_textField setKeyboardType:UIKeyboardTypeAlphabet];
    
    [_textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    
    [self addSubview:_textField];
}

- (UITextField *)textField{
    return _textField;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)drawLine{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat cellWidth = self.bounds.size.width;
    
    CGFloat xInset = 4;
    
    CGFloat x1 = xInset;
    CGFloat x2 = cellWidth - xInset;
    
    CGFloat y = self.bounds.size.height;
    
    UIColor *grayColor = kFZZGrayTextColor();
    
    CGFloat whiteness;
    CGFloat alpha;
    
    [grayColor getWhite:&whiteness alpha:&alpha];
    
    [UIColor colorWithWhite:whiteness alpha:alpha];
    
    CGContextSetStrokeColorWithColor(context, [kFZZGrayTextColor() CGColor]);
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, x1, y);
    CGContextAddLineToPoint(context, x2, y);
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if (_shouldDrawLine){
        [self drawLine];
    }
}

@end
